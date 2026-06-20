---
displayed_sidebar: injectcontainerSidebar
title: Architecture Overview
sidebar_position: 1
---

## Unit structure

InjectContainer is composed of five units, each with a single responsibility:

| Unit | Class(es) | Responsibility |
|---|---|---|
| `Inject.pas` | `TInject` | Public facade — registration, resolution, logging, RTTI cache |
| `Inject.Container.pas` | `TInjectContainer` | Base container — shared dictionary state |
| `Inject.Factory.pas` | `TInjectFactory` | RTTI-driven object construction |
| `Inject.Service.pas` | `TServiceData`, `TInjectionMode` | Service descriptor — holds class, GUID, instance, lifecycle |
| `Inject.Events.pas` | `TInjectEvents`, `TConstructorCallback` | Lifecycle callback holder |
| `Inject.Service.Abstract.pas` | `TServiceDataAbstract` | Base class for services that need an `FOwner: TInject` reference |

## Inheritance chain

```
TObject
  └── TInjectAbstract
        └── TInjectContainer     (Inject.Container)
              └── TInject        (Inject)
```

`TInjectContainer` owns and initializes all shared data structures. `TInject` adds the public API, RTTI cache, logging, and dependency-stack tracking.

## Data flow: registration

```
caller → TInject.Singleton<T>
           │
           ├─ check FRepositoryReference (duplicate guard)
           ├─ add T.ClassName → TServiceData to FRepositoryReference
           ├─ FInjectorFactory.FactorySingleton<T>()   ← constructs TServiceData via RTTI
           ├─ add TServiceData to FInstances
           └─ _AddEvents<T>()   ← stores OnCreate/OnDestroy/OnParams in FInjectorEvents
```

## Data flow: resolution

```
caller → TInject.Get<T>
           │
           ├─ GetTry<T>
           │    ├─ _PushDependency(T.ClassName)   ← circular-dependency check
           │    ├─ look up FInstances[T.ClassName]
           │    ├─ if nil → FInjectorFactory.FactorySingleton<T>  (lazy path)
           │    ├─ _ResolverParams(ServiceClass)  ← auto-wire constructor args via RTTI cache
           │    ├─ TServiceData.GetInstance<T>(Events, Params)
           │    │    ├─ imSingleton → reuse FInstance (or construct once)
           │    │    └─ imFactory   → construct fresh instance every time
           │    └─ _PopDependency
           │
           └─ if not found → cascade into child TInject instances in FInstances
```

## Internal dictionaries

| Field | Type | Keys | Values |
|---|---|---|---|
| `FRepositoryReference` | `TDictionary<string, TClass>` | `T.ClassName` or ATag | The registered `TClass` |
| `FRepositoryInterface` | `TDictionary<string, TPair<TClass, TGUID>>` | `GUIDToString(I)` or ATag | `(TClass, TGUID)` pair |
| `FInstances` | `TObjectDictionary<string, TServiceData>` | Same keys | `TServiceData` descriptor (owns values) |
| `FInjectorEvents` | `TObjectDictionary<string, TInjectEvents>` | Same keys | `TInjectEvents` callback holder |
| `FTypeCache` | `TDictionary<string, TRttiType>` | `IntToHex(TClass pointer)` | `TRttiType` |
| `FMethodCache` | `TDictionary<string, TRttiMethod>` | `IntToHex(TClass pointer).MethodName` | `TRttiMethod` |
| `FDependencyStack` | `TList<string>` | — | Service names currently being resolved |

## Global singleton pattern

The framework exposes a process-wide injector via:

```pascal
var
  GPInjector  : PInject = nil;    // pointer to the global TInject
  GInjectorLock: TCriticalSection; // guards pointer access
```

`GetInjector` acquires `GInjectorLock` before returning `GPInjector^`, making the global accessor thread-safe. The instance is created in `initialization` and freed in `finalization`.
