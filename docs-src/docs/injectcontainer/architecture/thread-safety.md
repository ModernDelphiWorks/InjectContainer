---
displayed_sidebar: injectcontainerSidebar
title: Thread Safety
sidebar_position: 3
---

InjectContainer is designed for **highly concurrent multi-threaded server environments**. Thread safety is achieved at three levels.

## Level 1 — Global injector accessor

The process-wide injector pointer is guarded by `GInjectorLock`:

```pascal
function GetInjector: TInject;
begin
  GInjectorLock.Enter;
  try
    if Assigned(GPInjector) then
      Result := GPInjector^
    else
      Result := nil;
  finally
    GInjectorLock.Leave;
  end;
end;
```

No thread can observe a partially initialized or freed global injector. `GInjectorLock` is created in `initialization` before `GPInjector` is set.

## Level 2 — RTTI cache

`FRttiCacheLock: TCriticalSection` serializes all reads and writes to `FTypeCache` and `FMethodCache`. See [RTTI Cache](rtti-cache.md) for details.

## Level 3 — Dependency stack

`FDependencyStack: TList<string>` tracks the in-progress resolution chain for circular dependency detection. It is an **instance field** on `TInject`, not a global or thread-local structure.

:::warning Current threading model
The dependency stack is **not thread-local**. If two threads simultaneously resolve services that share a dependency path, the stack-based circular dependency check may produce false positives or missed detections under concurrent resolution.

For single-threaded resolution at startup (the typical pattern), this is not an issue. For fully concurrent resolution of new lazy services from multiple threads simultaneously, guard the resolution call externally or register all services at startup before spawning worker threads. The current implementation uses a single shared `TList<string>` field (`FDependencyStack`) with no thread-local variant; there is no per-thread stack in the present source.
:::

## Recommended threading pattern

```pascal
// --- Main thread / startup ---
// Register all services before spawning worker threads
GetInjector.SingletonInterface<IEmailService, TEmailService>;
GetInjector.SingletonInterface<IUserService, TUserService>;
GetInjector.Singleton<TConnectionPool>;
// At this point all singletons are constructed and cached

// --- Worker threads ---
// Safe to call GetInterface / Get concurrently because singletons are cached
TThread.CreateAnonymousThread(
  procedure
  var LSvc: IEmailService;
  begin
    LSvc := GetInjector.GetInterface<IEmailService>; // no construction needed
    LSvc.Send('x@y.com', 'Hello');
  end
).Start;
```

The safe rule is: **construct all singletons at startup from a single thread; worker threads only resolve (never register new lazy services concurrently)**.

## Singleton instance pooling

For `imSingleton` mode, `TServiceData.GetInstance<T>` checks `FInstance` before constructing:

```pascal
imSingleton:
begin
  if not Assigned(FInstance) then
    FInstance := _FactoryInstance<T>(AInjectorEvents, AParams);
  Result := FInstance as T;
end;
```

This check is **not guarded by a lock in `TServiceData`** itself — the assumption is that concurrent first-resolution is prevented by the recommended startup pattern above.
