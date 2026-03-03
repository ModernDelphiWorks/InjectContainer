{
  ------------------------------------------------------------------------------
  InjectContainer
  Lightweight dependency injection container for Delphi applications.

  SPDX-License-Identifier: Apache-2.0
  Copyright (c) 2025-2026 Isaque Pinheiro

  Licensed under the Apache License, Version 2.0.
  See the LICENSE file in the project root for full license information.
  ------------------------------------------------------------------------------
}

unit Inject.Events;


interface

uses
  System.Rtti,
  System.SysUtils;

type
  TConstructorParams = TArray<TValue>;
  TConstructorCallback = TFunc<TConstructorParams>;

  TInjectEvents = class
  private
    FOnDestroy: TProc<TObject>;
    FOnCreate: TProc<TObject>;
    FOnParams: TConstructorCallback;
    procedure _SetOnDestroy(const AOnDestroy: TProc<TObject>);
    procedure _SetOnCreate(const AOnCreate: TProc<TObject>);
    procedure _SetOnParams(const Value: TConstructorCallback);
  public
    property OnDestroy: TProc<TObject> read FOnDestroy write _SetOnDestroy;
    property OnCreate: TProc<TObject> read FOnCreate write _SetOnCreate;
    property OnParams: TConstructorCallback read FOnParams write _SetOnParams;
  end;

implementation

{ TInjectorEvents }

procedure TInjectEvents._SetOnDestroy(const AOnDestroy: TProc<TObject>);
begin
  FOnDestroy := TProc<TObject>(AOnDestroy);
end;

procedure TInjectEvents._SetOnParams(const Value: TConstructorCallback);
begin
  FOnParams := Value;
end;

procedure TInjectEvents._SetOnCreate(const AOnCreate: TProc<TObject>);
begin
  FOnCreate := AOnCreate;
end;

end.
