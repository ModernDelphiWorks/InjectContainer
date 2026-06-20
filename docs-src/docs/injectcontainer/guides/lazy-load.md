---
displayed_sidebar: injectcontainerSidebar
title: Lazy Load (SingletonLazy)
sidebar_position: 3
---

**SingletonLazy** combines the shared-instance guarantee of a Singleton with deferred construction: the object is not created until the first time it is requested.

## Method signature

```pascal
procedure SingletonLazy<T: class>(
  const AOnCreate: TProc<T> = nil;
  const AOnDestroy: TProc<T> = nil;
  const AOnConstructorParams: TConstructorCallback = nil);
```

Declared in unit `Inject`, class `TInject`.

:::note
`SingletonLazy` accepts `T: class` only (no `constructor` constraint). The actual construction is deferred and driven by RTTI inside `GetTry<T>`.
:::

## Basic usage

```pascal
uses
  Inject;

// Register — nothing is constructed yet
GetInjector.SingletonLazy<TExpensiveService>;

// First Get<T> → constructs and caches the instance
var LSvc := GetInjector.Get<TExpensiveService>;

// Subsequent calls → same cached instance
var LSvc2 := GetInjector.Get<TExpensiveService>;
// LSvc = LSvc2
```

## Difference from `Singleton`

| Aspect | `Singleton` | `SingletonLazy` |
|---|---|---|
| Instance created at | Registration time | First resolution |
| Good for | Services always needed at startup | Services that may never be needed |
| Constructor access | Immediate | Via RTTI at first `Get<T>` call |

## With callbacks

```pascal
GetInjector.SingletonLazy<TReportGenerator>(
  procedure(const AGen: TReportGenerator)
  begin
    AGen.OutputPath := 'C:\Reports';
  end,
  procedure(const AGen: TReportGenerator)
  begin
    AGen.Flush;
  end
);
```

## Interaction with events

Inside `GetTry<T>`, the container calls `_ResolverParams` to auto-wire constructor parameters from the container when no `TConstructorCallback` is provided. This means that if `TExpensiveService` requires other registered services in its constructor, they are resolved automatically at lazy-instantiation time.
