---
displayed_sidebar: injectcontainerSidebar
title: Interface Binding
sidebar_position: 4
---

Interface binding maps a Delphi `IInterface`-derived type to a concrete class. The container resolves the binding by GUID, so the caller only depends on the interface, never the implementation.

## Method signature

```pascal
procedure SingletonInterface<I: IInterface; T: class, constructor>(
  const ATag: string = '';
  const AOnCreate: TProc<T> = nil;
  const AOnDestroy: TProc<T> = nil;
  const AOnConstructorParams: TConstructorCallback = nil);
```

Declared in unit `Inject`, class `TInject`.

## Prerequisites

Your interface **must** have a GUID attribute:

```pascal
type
  IMyService = interface
    ['{12345678-ABCD-EF01-2345-6789ABCDEF01}']
    procedure DoWork;
  end;
```

The GUID is used as the registry key internally (`GUIDToString`).

## Basic registration and resolution

```pascal
uses
  Inject, MyServices;

// Registration (typically in unit initialization)
GetInjector.SingletonInterface<IMyService, TMyServiceImpl>;

// Resolution (in any consumer)
var LSvc: IMyService;
LSvc := GetInjector.GetInterface<IMyService>;
LSvc.DoWork;
```

## Resolution method

```pascal
function GetInterface<I: IInterface>(const ATag: string = ''): I;
```

- Looks up the GUID of `I` in `FRepositoryInterface`.
- If found and not yet instantiated, creates via RTTI and caches the `TValue`.
- Raises `EServiceNotFound` if the interface is not registered.

## Using ATag for multiple registrations

If you need multiple implementations of the same interface (e.g., different strategies), use the `ATag` parameter to distinguish them:

```pascal
GetInjector.SingletonInterface<IPaymentGateway, TStripeGateway>('stripe');
GetInjector.SingletonInterface<IPaymentGateway, TPayPalGateway>('paypal');

var LStripe := GetInjector.GetInterface<IPaymentGateway>('stripe');
var LPayPal := GetInjector.GetInterface<IPaymentGateway>('paypal');
```

## Real example from the DependencyInjection_Interface sample

```pascal
// In unit initialization — wires the DFe engine to a concrete ACBr provider
initialization
  GetInjector.SingletonInterface<IDFeEngine, TDFeEngineACBr>;

// In a controller constructor — consumer only knows IDFeEngine
constructor TGlobalController.Create;
begin
  inherited;
  FDFeEngine := GetInjector.GetInterface<IDFeEngine>;
end;
```

## Error handling

| Condition | Exception raised |
|---|---|
| Interface already registered with same GUID/tag | `EServiceAlreadyRegistered` |
| Interface not registered at resolution time | `EServiceNotFound` |
