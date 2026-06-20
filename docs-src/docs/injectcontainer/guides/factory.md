---
displayed_sidebar: injectcontainerSidebar
title: Registering Factories
sidebar_position: 2
---

A **Factory** registration tells the container to create a **new instance on every resolution call**. The container does not retain ownership of factory-created instances once returned.

## Method signature

```pascal
procedure Factory<T: class, constructor>(
  const AOnCreate: TProc<T> = nil;
  const AOnDestroy: TProc<T> = nil;
  const AOnConstructorParams: TConstructorCallback = nil);
```

Declared in unit `Inject`, class `TInject`.

## Basic usage

```pascal
uses
  Inject;

// Register
GetInjector.Factory<TEmailMessage>;

// Resolve — each call produces a fresh TEmailMessage
var LMsg1 := GetInjector.Get<TEmailMessage>;
var LMsg2 := GetInjector.Get<TEmailMessage>;
// LMsg1 <> LMsg2 (different instances)
```

## With an OnCreate callback

```pascal
GetInjector.Factory<TEmailMessage>(
  procedure(const AMsg: TEmailMessage)
  begin
    AMsg.From := 'noreply@example.com';
  end
);
```

## When to use Factory vs Singleton

| Situation | Lifecycle |
|---|---|
| Shared, stateful service (e.g., database connection pool) | Singleton |
| Stateless request/message object created frequently | Factory |
| Service used from multiple threads with mutable state | Factory (each thread owns its instance) |
| Expensive to construct; only one needed | Singleton or SingletonLazy |

## Memory management

Factory-created instances are **not retained** by the container. The caller is responsible for freeing them (or using interface reference counting if the type implements `IInterface`).

:::warning
Registering a class as `Factory` and calling `Get<T>` in a tight loop can create GC pressure. Consider registering as `Singleton` or using a pool pattern if the class is expensive to construct.
:::

The README notes that InjectContainer's memory pool optimizations reduce heap overhead by **20–30%** for high-frequency factory instantiations compared to raw RTTI construction.
