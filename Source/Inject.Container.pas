{
  ------------------------------------------------------------------------------
  InjectContainer
  High-performance, thread-safe Dependency Injection (DI) framework for Delphi.

  SPDX-License-Identifier: MIT
  Copyright (c) 2025-2026 Isaque Pinheiro

  Licensed under the MIT License.
  See the LICENSE file in the project root for full license information.
  ------------------------------------------------------------------------------
}

unit Inject.Container;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  Inject.Factory,
  Inject.Service,
  Inject.Events;

type
  TInjectAbstract = class
  end;

  TInjectContainer = class(TInjectAbstract)
  private
    FName: string;
  protected
    FInjectorFactory: TInjectFactory;
    FRepositoryReference: TDictionary<string, TClass>;
    FRepositoryInterface: TDictionary<string, TPair<TClass, TGUID>>;
    FInstances: TObjectDictionary<string, TServiceData>;
    FInjectorEvents: TConstructorEvents;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    property Name: string read FName write FName;
  end;

implementation

{ TInjectorFactory }

constructor TInjectContainer.Create;
begin
  FInjectorFactory := TInjectFactory.Create;
  FRepositoryReference := TDictionary<string, TClass>.Create;
  FRepositoryInterface := TDictionary<string, TPair<TClass, TGUID>>.Create;
  FInstances := TObjectDictionary<string, TServiceData>.Create([doOwnsValues]);
  FInjectorEvents := TConstructorEvents.Create([doOwnsValues]);
end;

destructor TInjectContainer.Destroy;
begin
  FRepositoryReference.Free;
  FRepositoryInterface.Free;
  FInjectorEvents.Free;
  FInjectorFactory.Free;
  FInstances.Free;
  inherited;
end;

end.


