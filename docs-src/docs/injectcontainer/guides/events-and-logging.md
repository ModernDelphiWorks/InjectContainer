---
displayed_sidebar: injectcontainerSidebar
title: Events and Lifecycle Logging
sidebar_position: 6
---

InjectContainer has two distinct event systems: **lifecycle callbacks** attached to individual registrations, and a **global logging hook** for container-wide observability.

## Lifecycle callbacks (per registration)

Every registration method (`Singleton`, `SingletonLazy`, `SingletonInterface`, `Factory`) accepts three optional callback parameters:

| Parameter | Type | Fires |
|---|---|---|
| `AOnCreate` | `TProc<T>` | Immediately after the instance is constructed |
| `AOnDestroy` | `TProc<T>` | When `Remove<T>` is called before the instance is freed |
| `AOnConstructorParams` | `TConstructorCallback` (`TFunc<TConstructorParams>`) | When the container needs to resolve constructor parameters; return value overrides auto-wiring |

These are stored as `TInjectEvents` objects keyed by class name (or GUID string for interfaces) inside `FInjectorEvents`.

### Example: configure on create, flush on destroy

```pascal
uses
  Inject;

GetInjector.Singleton<TFileLogger>(
  // OnCreate — configure right after construction
  procedure(const ALogger: TFileLogger)
  begin
    ALogger.FilePath := 'C:\Logs\app.log';
    ALogger.MaxSizeKB := 10240;
  end,
  // OnDestroy — flush before free
  procedure(const ALogger: TFileLogger)
  begin
    ALogger.Flush;
  end
);
```

### Example: manual constructor parameters

```pascal
GetInjector.Singleton<TSmtpClient>(
  nil, nil,
  // OnConstructorParams — return explicit args for Create
  function: TConstructorParams
  begin
    Result := [
      TValue.From('smtp.example.com'),
      TValue.From(587)
    ];
  end
);
```

## Global logging

InjectContainer wraps every public operation with an optional logging path. Enable it with a `TProc<string>` callback:

```pascal
procedure EnableLogging(const ALogCallback: TProc<string> = nil);
procedure DisableLogging;
```

### Enable with a custom sink

```pascal
GetInjector.EnableLogging(
  procedure(const AMsg: string)
  begin
    Writeln(AMsg);
    // or: TLogger.Instance.Info(AMsg);
  end
);
```

### Enable with nil (structured output to internal log only)

```pascal
GetInjector.EnableLogging; // ALogCallback = nil → logs silently
```

### Log format

Each log entry is formatted as:

```
[Injector4D] hh:nn:ss.zzz - <Operation>: <ServiceName>
```

Operations logged:
- `Add Singleton` — on `Singleton<T>` call
- `Add Factory` — on `Factory<T>` call
- `Get Service` — on `Get<T>` call
- `Get Interface` — on `GetInterface<I>` call
- `Service resolved` / `Service resolved from child injector`
- `Interface resolved` / `Interface not found`
- `Logging enabled` / `Logging disabled`
- `Clearing RTTI cache`

### Disable logging

```pascal
GetInjector.DisableLogging;
```

## Clearing the RTTI cache

```pascal
procedure ClearCache;
```

Forces the internal `FTypeCache` and `FMethodCache` dictionaries to clear. Call this if the metadata cache grows unexpectedly large (e.g., after dynamically loading/unloading packages).

```pascal
GetInjector.ClearCache;
```

## TInjectEvents internals

Stored in `FInjectorEvents: TConstructorEvents` (a `TObjectDictionary<string, TInjectEvents>`). Each `TInjectEvents` holds:

```pascal
property OnDestroy: TProc<TObject>;
property OnCreate:  TProc<TObject>;
property OnParams:  TConstructorCallback;
```

The callbacks are stored as `TProc<TObject>` internally and cast to `TProc<T>` at call sites, keeping the dictionary type-homogeneous while preserving the generic-typed API.
