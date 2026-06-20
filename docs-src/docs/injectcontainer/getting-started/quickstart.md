---
displayed_sidebar: injectcontainerSidebar
title: Quickstart
sidebar_position: 2
---

This guide walks you through wiring up a minimal InjectContainer application end-to-end in five steps.

## 1. Define your service interfaces and implementations

```pascal
unit MyServices;

interface

type
  IEmailService = interface
    ['{A1B2C3D4-0000-0000-0000-000000000001}']
    procedure Send(const ATo, ABody: string);
  end;

  TEmailService = class(TInterfacedObject, IEmailService)
  public
    procedure Send(const ATo, ABody: string);
  end;

  IUserService = interface
    ['{A1B2C3D4-0000-0000-0000-000000000002}']
    procedure CreateUser(const AName: string);
  end;

  TUserService = class(TInterfacedObject, IUserService)
  private
    FEmail: IEmailService;
  public
    constructor Create;
    procedure CreateUser(const AName: string);
  end;

implementation

uses
  Inject, SysUtils;

procedure TEmailService.Send(const ATo, ABody: string);
begin
  Writeln('Sending to ', ATo, ': ', ABody);
end;

constructor TUserService.Create;
begin
  inherited;
  // Resolve IEmailService from the global injector
  FEmail := GetInjector.GetInterface<IEmailService>;
end;

procedure TUserService.CreateUser(const AName: string);
begin
  FEmail.Send('admin@example.com', 'New user: ' + AName);
end;

initialization
  // Register services when the unit loads
  GetInjector.SingletonInterface<IEmailService, TEmailService>;
  GetInjector.SingletonInterface<IUserService, TUserService>;

end.
```

## 2. Bootstrap in the application entry point

```pascal
program MyApp;

uses
  MyServices,
  Inject;

{$R *.res}

begin
  // The global injector (GPInjector^) is already created at unit
  // initialization time — no explicit Build call is required.
  // Just ensure the units that register services are in the uses list.

  var LUser := GetInjector.GetInterface<IUserService>;
  LUser.CreateUser('Alice');
end.
```

## 3. Resolve and use

```pascal
uses
  Inject, MyServices;

var
  LEmail: IEmailService;
begin
  // Resolve by interface
  LEmail := GetInjector.GetInterface<IEmailService>;
  LEmail.Send('bob@example.com', 'Hello!');
end;
```

## 4. Register a Factory (new instance per resolution)

```pascal
uses
  Inject, MyServices;

// Register TEmailService as a Factory instead of a Singleton
GetInjector.Factory<TEmailService>;

// Each call returns a fresh TEmailService instance
var LSvc1 := GetInjector.Get<TEmailService>;
var LSvc2 := GetInjector.Get<TEmailService>;
// LSvc1 <> LSvc2
```

## 5. Enable lifecycle logging

```pascal
uses
  Inject;

GetInjector.EnableLogging(
  procedure(const AMsg: string)
  begin
    Writeln(AMsg);
  end
);
```

:::tip
All four lifecycle types — `Singleton`, `SingletonLazy`, `SingletonInterface`, and `Factory` — can coexist in the same container. See the individual [Guides](../guides/singleton.md) for detailed usage of each.
:::
