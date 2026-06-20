---
displayed_sidebar: injectcontainerSidebar
title: API Reference
sidebar_position: 1
---

## Global accessor

```pascal
function GetInjector: TInject;
```

Returns the process-wide `TInject` instance. Thread-safe: acquires `GInjectorLock` before returning the pointer. Returns `nil` if the injector has been destroyed.

## TInject — Registration methods

### Singleton

```pascal
procedure Singleton<T: class, constructor>(
  const AOnCreate: TProc<T> = nil;
  const AOnDestroy: TProc<T> = nil;
  const AOnConstructorParams: TConstructorCallback = nil); overload;
```

Registers `T` as a Singleton. The instance is created immediately and stored. Raises `Exception` if `T` is already registered.

### SingletonLazy

```pascal
procedure SingletonLazy<T: class>(
  const AOnCreate: TProc<T> = nil;
  const AOnDestroy: TProc<T> = nil;
  const AOnConstructorParams: TConstructorCallback = nil);
```

Registers `T` as a lazy Singleton. No instance is created at registration; construction is deferred to the first `Get<T>` call. Raises `EServiceAlreadyRegistered` if already registered.

### SingletonInterface

```pascal
procedure SingletonInterface<I: IInterface; T: class, constructor>(
  const ATag: string = '';
  const AOnCreate: TProc<T> = nil;
  const AOnDestroy: TProc<T> = nil;
  const AOnConstructorParams: TConstructorCallback = nil);
```

Registers the interface `I` → implementation `T` mapping. The interface `I` must declare a GUID. Resolution key: `GUIDToString(GetTypeData(TypeInfo(I)).Guid)`, or `ATag` if non-empty. Raises `EServiceAlreadyRegistered` if already registered.

### Factory

```pascal
procedure Factory<T: class, constructor>(
  const AOnCreate: TProc<T> = nil;
  const AOnDestroy: TProc<T> = nil;
  const AOnConstructorParams: TConstructorCallback = nil);
```

Registers `T` as a Factory. A new instance is constructed on every `Get<T>` call. Raises `Exception` if already registered.

### AddInject

```pascal
procedure AddInject(const ATag: string; const AInstance: TInject);
```

Registers another `TInject` as a child injector under `ATag`. Resolution cascades into child injectors when the parent cannot find a service. Raises `EServiceAlreadyRegistered` if `ATag` is already in use.

### AddInstance

```pascal
procedure AddInstance<T: class>(const AInstance: TObject);
```

Registers an already-constructed object as a Singleton under `T.ClassName`. The container takes ownership (frees the instance on removal or destruction). Raises `EServiceAlreadyRegistered` if already registered.

---

## TInject — Resolution methods

### Get

```pascal
function Get<T: class, constructor>(const ATag: string = ''): T;
```

Resolves the registered service for `T` (or `ATag` if non-empty). Returns `nil` if not found (does not raise). Cascades into child injectors.

### GetInterface

```pascal
function GetInterface<I: IInterface>(const ATag: string = ''): I;
```

Resolves the registered interface `I`. Raises `EServiceNotFound` if not registered anywhere in the injector tree.

### GetInstances

```pascal
function GetInstances: TObjectDictionary<string, TServiceData>;
```

Returns the internal instance dictionary. For diagnostics only — do not modify.

---

## TInject — Maintenance methods

### Remove

```pascal
procedure Remove<T: class>(const ATag: string = '');
```

Fires `OnDestroy` (if registered), removes all entries for `T` / `ATag` from internal dictionaries, and frees the singleton instance.

### EnableLogging

```pascal
procedure EnableLogging(const ALogCallback: TProc<string> = nil);
```

Activates operation logging. If `ALogCallback` is `nil`, log messages are generated but not delivered anywhere (useful if you wire the callback later).

### DisableLogging

```pascal
procedure DisableLogging;
```

Deactivates logging and clears `FLogCallback`.

### ClearCache

```pascal
procedure ClearCache;
```

Clears `FTypeCache` and `FMethodCache` under `FRttiCacheLock`. Does not destroy `FRttiContext`.

---

## Exceptions

| Exception class | Parent | Raised when |
|---|---|---|
| `EInjectException` | `Exception` | Base for all InjectContainer exceptions |
| `EServiceAlreadyRegistered` | `EInjectException` | Duplicate registration |
| `EServiceNotFound` | `EInjectException` | `GetInterface<I>` cannot find `I` |
| `ECircularDependency` | `EInjectException` | Circular dependency detected in resolution stack |

---

## Types

| Type | Declaration | Description |
|---|---|---|
| `TInjectionMode` | `(imSingleton, imFactory)` | Lifecycle mode stored in `TServiceData` |
| `TConstructorParams` | `TArray<TValue>` | Parameter array passed to RTTI constructor call |
| `TConstructorCallback` | `TFunc<TConstructorParams>` | Callback that returns constructor parameters |
| `TConstructorEvents` | `TObjectDictionary<string, TInjectEvents>` | Container-level event dictionary type |

---

## TServiceData (internal)

`TServiceData` is the internal descriptor for every registered service. It is not part of the public surface but its behavior drives resolution:

| Method | Purpose |
|---|---|
| `GetInstance<T>(Events, Params)` | Returns cached or new instance based on `TInjectionMode` |
| `GetInterface<I>(Key, Events, Params)` | Returns cached interface value |
| `AsInstance` | Returns `FInstance` as `TObject` |
| `ServiceClass` | Returns the registered `TClass` |
| `InjectionMode` | Returns `TInjectionMode` |
