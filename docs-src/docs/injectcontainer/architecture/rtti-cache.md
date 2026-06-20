---
displayed_sidebar: injectcontainerSidebar
title: RTTI Cache
sidebar_position: 2
---

InjectContainer's RTTI cache is the primary source of its performance advantage over frameworks that call standard Delphi RTTI on every resolution.

## The problem with raw RTTI

Every call to `TRttiContext.GetType(AClass)` and `TRttiType.GetMethod('Create')` performs dictionary lookups and string hashing inside the RTL. In a high-throughput server application resolving hundreds of services per request, this adds measurable latency.

## The solution: two-tier in-process cache

`TInject` maintains two `TDictionary` fields guarded by a single `TCriticalSection` (`FRttiCacheLock`):

| Cache field | Key | Value | Populated by |
|---|---|---|---|
| `FTypeCache` | `IntToHex(NativeInt(AClass))` | `TRttiType` | `_GetCachedType` |
| `FMethodCache` | `IntToHex(NativeInt(AClass)) + '.' + MethodName` | `TRttiMethod` | `_GetCachedMethod` |

The key is the **class pointer in hex** (not the class name string), avoiding an extra string allocation on each lookup.

## Cache hit path

```pascal
function TInject._GetCachedType(const AClass: TClass): TRttiType;
begin
  LClassKey := IntToHex(NativeInt(AClass), SizeOf(Pointer) * 2);
  FRttiCacheLock.Enter;
  try
    if FTypeCache.ContainsKey(LClassKey) then
      Result := FTypeCache[LClassKey]   // ← fast path: no RTTI call
    else
    begin
      Result := FRttiContext.GetType(AClass);
      if Assigned(Result) then
        FTypeCache.Add(LClassKey, Result);
    end;
  finally
    FRttiCacheLock.Leave;
  end;
end;
```

`_GetCachedMethod` is analogous: it checks `FMethodCache` before calling `TRttiType.GetMethod`.

## Performance characteristics

- **40–60% faster** than uncached RTTI, per README benchmarks.
- Cache is shared across all resolution calls from all threads (guarded by `FRttiCacheLock`).
- The `TRttiContext` (`FRttiContext`) is kept alive for the lifetime of the injector, avoiding repeated context creation/destruction.

## Cache invalidation

The cache does **not** invalidate automatically. If you dynamically load or unload BPL packages at runtime, call:

```pascal
GetInjector.ClearCache;
```

This calls `_ClearRttiCache`, which clears both `FTypeCache` and `FMethodCache` under the lock. The `TRttiContext` is not freed — only the lookup dictionaries are cleared.

## Thread safety of the cache

Both `_GetCachedType` and `_GetCachedMethod` acquire `FRttiCacheLock` before reading or writing. Multiple threads can safely call `Get<T>` and `GetInterface<I>` concurrently without data races in the cache.

The `TRttiContext` itself is not re-entrant in all Delphi versions, but because access is always serialized through `FRttiCacheLock`, concurrent access is safe.
