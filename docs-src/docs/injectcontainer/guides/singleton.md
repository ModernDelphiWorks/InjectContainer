---
displayed_sidebar: injectcontainerSidebar
title: Registering Singletons
sidebar_position: 1
---

A **Singleton** registration means the container creates the instance on first resolution and returns the same object for every subsequent call within the same injector.

## Method signature

```pascal
procedure Singleton<T: class, constructor>(
  const AOnCreate: TProc<T> = nil;
  const AOnDestroy: TProc<T> = nil;
  const AOnConstructorParams: TConstructorCallback = nil); overload;
```

Declared in unit `Inject`, class `TInject`.

## Basic usage

```pascal
uses
  Inject;

// Register — the instance is created immediately and cached
GetInjector.Singleton<TMyService>;

// Resolve — always returns the same instance
var LSvc := GetInjector.Get<TMyService>;
```

## With an OnCreate callback

Use `AOnCreate` to configure the instance right after construction:

```pascal
GetInjector.Singleton<TConnectionPool>(
  procedure(const APool: TConnectionPool)
  begin
    APool.MaxConnections := 20;
    APool.ConnectionString := 'localhost:3050';
  end
);
```

## With an OnDestroy callback

```pascal
GetInjector.Singleton<TConnectionPool>(
  nil, // AOnCreate
  procedure(const APool: TConnectionPool)
  begin
    APool.CloseAll;
  end
);
```

## With custom constructor parameters

When the class constructor requires arguments that cannot be auto-resolved from the container, supply `AOnConstructorParams`:

```pascal
GetInjector.Singleton<TMyService>(
  nil, nil,
  function: TConstructorParams
  begin
    Result := [TValue.From('ConfigValue'), TValue.From(42)];
  end
);
```

## Lifecycle behavior

| Event | Behavior |
|---|---|
| First `Get<T>` call | Instance is constructed and stored |
| Subsequent `Get<T>` calls | Cached instance is returned — no new allocation |
| `Remove<T>` call | `OnDestroy` fires, instance freed, entry removed from container |
| Container destruction | All owned instances are freed |

:::caution
`Singleton` creates the instance **at registration time** (not lazily). If you want construction to be deferred until first resolution, use [`SingletonLazy`](lazy-load.md) instead.
:::
