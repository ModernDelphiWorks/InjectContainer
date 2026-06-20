---
displayed_sidebar: injectcontainerSidebar
title: Child Injectors
sidebar_position: 7
---

InjectContainer supports **hierarchical composition**: a parent `TInject` can hold child `TInject` instances. When `Get<T>` or `GetInterface<I>` cannot find a service in the parent, it cascades into each registered child injector.

## Registering a child injector

```pascal
procedure AddInject(const ATag: string; const AInstance: TInject);
```

The child injector is stored as a `TServiceData` with mode `imSingleton` under the given tag, so it participates in the cascade automatically.

## Example: layered architecture

```pascal
uses
  Inject;

var
  LInfra  : TInject;
  LDomain : TInject;

begin
  // Infrastructure injector — data access services
  LInfra := TInject.Create;
  LInfra.Singleton<TDatabaseConnection>;
  LInfra.Singleton<TFileRepository>;

  // Domain injector — business logic services  
  LDomain := TInject.Create;
  LDomain.Singleton<TOrderService>;

  // Compose: parent holds both children
  GetInjector.AddInject('infra', LInfra);
  GetInjector.AddInject('domain', LDomain);

  // Resolving from the root finds services in any child
  var LConn  := GetInjector.Get<TDatabaseConnection>; // from LInfra
  var LOrder := GetInjector.Get<TOrderService>;        // from LDomain
end;
```

## Cascade order

Resolution is attempted in this order:

1. Current injector's own `FRepositoryReference` / `FRepositoryInterface`.
2. Each child `TInject` stored in `FInstances` (in insertion order).
3. If none found: `Get<T>` returns `nil`; `GetInterface<I>` raises `EServiceNotFound`.

## AddInstance — registering existing objects

```pascal
procedure AddInstance<T: class>(const AInstance: TObject);
```

Registers an already-constructed object as a Singleton without using RTTI construction. Useful for bridging external dependencies (e.g., a third-party object created before the DI container started).

```pascal
var LExternalLogger := TThirdPartyLogger.Create('config.ini');
GetInjector.AddInstance<TThirdPartyLogger>(LExternalLogger);

// Later
var LLogger := GetInjector.Get<TThirdPartyLogger>;
```

:::caution
The container takes ownership of instances registered via `AddInstance` and will free them when the injector is destroyed or `Remove<T>` is called.
:::
