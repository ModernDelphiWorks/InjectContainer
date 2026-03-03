{
  ------------------------------------------------------------------------------
  InjectContainer
  Lightweight and modular Dependency Injection container for Delphi.
  Copyright (c) 2023-2026 Isaque Pinheiro

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
  ------------------------------------------------------------------------------
}

{
  @abstract(InjectContainer - Modular Dependency Injection for Delphi)

  @description(
    InjectContainer provides a lightweight, extensible, and modular
    dependency injection container for Delphi applications.
    It supports constructor injection, service registration,
    lifetime management, and clean architecture patterns.
  )

  @author(Isaque Pinheiro)
  @created(2023-04-03)
}

unit Factory;

interface

uses
  Rtti,
  SysUtils,
  Service;

type
  TInjectFactory = class
  private
    function _FactoryInternal(const Args: TArray<TValue>): TServiceData;
  public
    function FactorySingleton<T: class, constructor>(): TServiceData;
    function FactoryInterface<I: IInterface>(const AClass: TClass;
      const AGuid: TGUID): TServiceData;
    function Factory<T: class, constructor>(): TServiceData;
  end;

implementation

{ TInjectorFactory }

function TInjectFactory.Factory<T>(): TServiceData;
var
  LArgs: TArray<TValue>;
begin
  SetLength(LArgs, 3);
  LArgs[0] := TValue.From<TClass>(T);
  LArgs[1] := TValue.From<TObject>(nil);
  LArgs[2] := TValue.From<TInjectionMode>(TInjectionMode.imFactory);
  Result := _FactoryInternal(LArgs);
end;

function TInjectFactory.FactoryInterface<I>(const AClass: TClass;
  const AGuid: TGUID): TServiceData;
var
  LArgs: TArray<TValue>;
begin
  SetLength(LArgs, 4);
  LArgs[0] := TValue.From<TClass>(AClass);
  LArgs[1] := TValue.From<TGUID>(AGuid);
  LArgs[2] := TValue.From<TValue>(TValue.Empty);
  LArgs[3] := TValue.From<TInjectionMode>(TInjectionMode.imSingleton);
  Result := _FactoryInternal(LArgs);
end;

function TInjectFactory.FactorySingleton<T>(): TServiceData;
var
  LArgs: TArray<TValue>;
begin
  SetLength(LArgs, 3);
  LArgs[0] := TValue.From<TClass>(T);
  LArgs[1] := TValue.From<TObject>(nil);
  LArgs[2] := TValue.From<TInjectionMode>(TInjectionMode.imSingleton);
  Result := _FactoryInternal(LArgs);
end;

function TInjectFactory._FactoryInternal(const Args: TArray<TValue>): TServiceData;
var
  LContext: TRttiContext;
  LTypeService: TRttiType;
  LConstructorMethod: TRttiMethod;
  LInstance: TValue;
begin
  LContext := TRttiContext.Create;
  try
    LTypeService := LContext.GetType(TServiceData);
    if Length(Args) = 3 then
      LConstructorMethod := LTypeService.GetMethod('Create')
    else
      LConstructorMethod := LTypeService.GetMethod('CreateInterface');
    LInstance := LConstructorMethod.Invoke(LTypeService.AsInstance.MetaClassType, Args);
    Result := TServiceData(LInstance.AsObject);
  finally
    LContext.Free;
  end;
end;

end.
