---
displayed_sidebar: injectcontainerSidebar
title: Resolving Dependencies
sidebar_position: 5
---

InjectContainer provides two primary resolution methods and several helper methods for advanced scenarios.

## Resolving by concrete class

```pascal
function Get<T: class, constructor>(const ATag: string = ''): T;
```

Returns the registered instance (or a new one for Factory) for the class `T`. Returns `nil` if not found (does not raise for class resolution — check the return value).

```pascal
uses
  Inject;

var LSvc := GetInjector.Get<TMyService>;
if Assigned(LSvc) then
  LSvc.DoWork;
```

## Resolving by interface

```pascal
function GetInterface<I: IInterface>(const ATag: string = ''): I;
```

Looks up by GUID. Raises `EServiceNotFound` if not registered.

```pascal
var LSvc: IMyService;
LSvc := GetInjector.GetInterface<IMyService>;
LSvc.DoWork;
```

## Auto-wiring constructor parameters

When a registered class has a constructor that takes parameters, InjectContainer auto-resolves them from the container at instantiation time via `_ResolverParams`. For each constructor parameter:

| Parameter kind | Resolution |
|---|---|
| `tkClass` / `tkClassRef` | `Get<TObject>` using the type name |
| `tkInterface` | `GetInterface<IInterface>` using the GUID |
| Other | `TValue.From(nil)` (no resolution) |

This means you can register a service that depends on other services without manual wiring:

```pascal
// TOrderService constructor takes IEmailService and ILogService
// Both are already registered — InjectContainer wires them automatically
GetInjector.SingletonLazy<TOrderService>;

// When first resolved, TOrderService.Create(IEmailService, ILogService)
// is called with the container-resolved values
var LOrders := GetInjector.Get<TOrderService>;
```

## Resolution cascade through child injectors

`Get<T>` and `GetInterface<I>` search the current injector first, then cascade into any registered child injectors (added via `AddInject`):

```pascal
// Child injector holds infrastructure services
var LInfra := TInject.Create;
LInfra.Singleton<TDatabaseConnection>;

// Parent injector holds business services
GetInjector.AddInject('infrastructure', LInfra);
GetInjector.SingletonLazy<TOrderRepository>;

// Resolving TDatabaseConnection from the parent works via cascade
var LConn := GetInjector.Get<TDatabaseConnection>;
```

## Removing a registration

```pascal
procedure Remove<T: class>(const ATag: string = '');
```

Calls `OnDestroy` if registered, then removes the type from all internal dictionaries and frees the instance (for Singleton/LazyLoad).

```pascal
GetInjector.Remove<TMyService>;
```

## Accessing all instances

```pascal
function GetInstances: TObjectDictionary<string, TServiceData>;
```

Returns the internal instance dictionary. Useful for diagnostics or iteration. Do not modify the returned dictionary directly.
