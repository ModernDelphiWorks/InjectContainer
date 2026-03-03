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

unit Inject;

interface

uses
  Rtti,
  TypInfo,
  SysUtils,
  SyncObjs,
  Generics.Collections,
  Inject.Service,
  Inject.Container,
  Inject.Events;

type
  // Exceções específicas do Injector4D
  EInjectException = class(Exception);
  EServiceAlreadyRegistered = class(EInjectException);
  EServiceNotFound = class(EInjectException);
  ECircularDependency = class(EInjectException);
  TConstructorParams = Inject.Events.TConstructorParams;

  PInject = ^TInject;
  TInject = class(TInjectContainer)
  strict private
    FDependencyStack: TList<string>;
    // Cache RTTI para melhorar performance
    FRttiContext: TRttiContext;
    FTypeCache: TDictionary<string, TRttiType>;
    FMethodCache: TDictionary<string, TRttiMethod>;
    FRttiCacheLock: TCriticalSection;
    // Sistema de logging opcional
    FLoggingEnabled: Boolean;
    FLogCallback: TProc<string>;
    procedure _AddEvents<T>(const AClassName: string;
      const AOnCreate: TProc<T>;
      const AOnDestroy: TProc<T>;
      const AOnConstructorParams: TConstructorCallback = nil);
    function _ResolverInterfaceType(const AHandle: PTypeInfo;
      const AGUID: TGUID): TValue;
    function _ResolverParams(const AClass: TClass): TConstructorParams; overload;
    procedure _CheckCircularDependency(const AServiceName: string);
    procedure _PushDependency(const AServiceName: string);
    procedure _PopDependency;
    // Métodos de cache RTTI
    function _GetCachedType(const AClassName: string): TRttiType;
    function _GetCachedMethod(const AClassName, AMethodName: string): TRttiMethod;
    procedure _ClearRttiCache;
    // Métodos de logging
    procedure _Log(const AMessage: string);
    procedure _LogOperation(const AOperation, AServiceName: string);
  protected
    function GetTry<T: class, constructor>(const ATag: string = ''): T;
    function GetInterfaceTry<I: IInterface>(const ATag: string = ''): I;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure AddInjector(const ATag: string;
      const AInstance: TInject);
    procedure AddInstance<T: class>(const AInstance: TObject);
//    procedure Singleton<T: class, constructor>(
//      const ATag: string = '';
//      const AOnCreate: TProc<T> = nil;
//      const AOnDestroy: TProc<T> = nil;
//      const AOnConstructorParams: TConstructorCallback = nil);
    procedure Singleton<T: class, constructor>(
      const AOnCreate: TProc<T> = nil;
      const AOnDestroy: TProc<T> = nil;
      const AOnConstructorParams: TConstructorCallback = nil); overload;
    procedure SingletonLazy<T: class>(
      const AOnCreate: TProc<T> = nil;
      const AOnDestroy: TProc<T> = nil;
      const AOnConstructorParams: TConstructorCallback = nil);
    procedure SingletonInterface<I: IInterface; T: class, constructor>(
      const ATag: string = '';
      const AOnCreate: TProc<T> = nil;
      const AOnDestroy: TProc<T> = nil;
      const AOnConstructorParams: TConstructorCallback = nil);
    procedure Factory<T: class, constructor>(
      const AOnCreate: TProc<T> = nil;
      const AOnDestroy: TProc<T> = nil;
      const AOnConstructorParams: TConstructorCallback = nil);
    procedure Remove<T: class>(const ATag: string = '');
    function GetInstances: TObjectDictionary<string, TServiceData>;
    function Get<T: class, constructor>(const ATag: string = ''): T;
    function GetInterface<I: IInterface>(const ATag: string = ''): I;
    // Métodos de logging público
    procedure EnableLogging(const ALogCallback: TProc<string> = nil);
    procedure DisableLogging;
    procedure ClearCache;
  end;

function GetInjector: TInject;

var
  GPInjector: PInject = nil;
  GInjectorLock: TCriticalSection = nil;

implementation

{ TInjectorBr }

constructor TInject.Create;
begin
  inherited Create;
  FDependencyStack := TList<string>.Create;
  // Inicializar cache RTTI
  FRttiContext := TRttiContext.Create;
  FTypeCache := TDictionary<string, TRttiType>.Create;
  FMethodCache := TDictionary<string, TRttiMethod>.Create;
  FRttiCacheLock := TCriticalSection.Create;
  // Inicializar logging
  FLoggingEnabled := False;
  FLogCallback := nil;
end;

destructor TInject.Destroy;
begin
  if Assigned(FDependencyStack) then
    FDependencyStack.Free;
  // Liberar cache RTTI
  if Assigned(FRttiCacheLock) then
    FRttiCacheLock.Free;
  if Assigned(FMethodCache) then
    FMethodCache.Free;
  if Assigned(FTypeCache) then
    FTypeCache.Free;
  FRttiContext.Free;
  inherited Destroy;
end;

function GetInjector: TInject;
begin
  if not Assigned(GInjectorLock) then
    Exit(nil);
  GInjectorLock.Enter;
  try
    if Assigned(GPInjector) then
      Result := GPInjector^
    else
      Result := nil;
  finally
    GInjectorLock.Leave;
  end;
end;

procedure TInject.Singleton<T>(const AOnCreate: TProc<T>;
  const AOnDestroy: TProc<T>;
  const AOnConstructorParams: TConstructorCallback);
var
  LValue: TServiceData;
  LKey: string;
begin
  LKey := T.ClassName;
  _LogOperation('Add Singleton', LKey);
  if FRepositoryReference.ContainsKey(LKey) then
    raise Exception.Create(Format('Class %s registered!', [LKey]));
  FRepositoryReference.Add(LKey, TServiceData);
  // Singleton
  LValue := FInjectorFactory.FactorySingleton<T>();
  FInstances.Add(LKey, LValue);
  // Events
  _AddEvents<T>(LKey, AOnCreate, AOnDestroy, AOnConstructorParams);
end;

procedure TInject.SingletonInterface<I, T>(const ATag: string;
  const AOnCreate: TProc<T>;
  const AOnDestroy: TProc<T>;
  const AOnConstructorParams: TConstructorCallback);
var
  LGuid: TGUID;
  LGuidstring: string;
begin
  LGuid := GetTypeData(TypeInfo(I)).Guid;
  LGuidstring := GUIDTostring(LGuid);
  if ATag <> '' then
    LGuidstring := ATag;
  if FRepositoryInterface.ContainsKey(LGuidstring) then
    raise EServiceAlreadyRegistered.Create(Format('Interface %s already registered!', [T.ClassName]));
  FRepositoryInterface.Add(LGuidstring, TPair<TClass, TGUID>.Create(T, LGuid));
  // Events
  _AddEvents<T>(LGuidstring, AOnCreate, AOnDestroy, AOnConstructorParams);
end;

procedure TInject.SingletonLazy<T>(const AOnCreate: TProc<T>;
  const AOnDestroy: TProc<T>;
  const AOnConstructorParams: TConstructorCallback);
begin
  if FRepositoryReference.ContainsKey(T.ClassName) then
    raise EServiceAlreadyRegistered.Create(Format('Class %s already registered!', [T.ClassName]));
  FRepositoryReference.Add(T.ClassName, TServiceData);
  // Events
  _AddEvents<T>(T.ClassName, AOnCreate, AOnDestroy, AOnConstructorParams);
end;

procedure TInject.AddInjector(const ATag: string;
  const AInstance: TInject);
var
  LValue: TServiceData;
begin
  if FRepositoryReference.ContainsKey(ATag) then
    raise EServiceAlreadyRegistered.Create(Format('Injector %s already registered!', [ATag]));
  FRepositoryReference.Add(ATag, TServiceData);
  LValue := TServiceData.Create(TInject,
                                AInstance,
                                TInjectionMode.imSingleton);
  FInstances.Add(ATag, LValue);
end;

procedure TInject.AddInstance<T>(const AInstance: TObject);
var
  LValue: TServiceData;
begin
  if FRepositoryReference.ContainsKey(T.ClassName) then
    raise EServiceAlreadyRegistered.Create(Format('Instance %s already registered!', [AInstance.ClassName]));
  FRepositoryReference.Add(T.ClassName, TServiceData);
  // Factory
  LValue := TServiceData.Create(T, AInstance, TInjectionMode.imSingleton);
  FInstances.Add(T.ClassName, LValue);
end;

procedure TInject.Factory<T>(const AOnCreate: TProc<T>;
  const AOnDestroy: TProc<T>;
  const AOnConstructorParams: TConstructorCallback);
var
  LValue: TServiceData;
begin
  _LogOperation('Add Factory', T.ClassName);
  if FRepositoryReference.ContainsKey(T.ClassName) then
    raise Exception.Create(Format('Class %s registered!', [T.ClassName]));
  FRepositoryReference.Add(T.ClassName, TServiceData);
  // Factory
  LValue := FInjectorFactory.Factory<T>();
  FInstances.Add(T.ClassName, LValue);
  // Events
  _AddEvents<T>(T.ClassName, AOnCreate, AOnDestroy, AOnConstructorParams);
end;

function TInject.GetInstances: TObjectDictionary<string, TServiceData>;
begin
  Result := FInstances;
end;

function TInject.Get<T>(const ATag: string): T;
var
  LItem: TServiceData;
  LTag: string;
begin
  LTag := ATag;
  if LTag = '' then
    LTag := T.ClassName;
  _LogOperation('Get Service', LTag);

  Result := GetTry<T>(ATag);
  if Result <> nil then
  begin
    _Log('Service resolved: ' + LTag);
    Exit;
  end;

  for LItem in GetInstances.Values do
  begin
    if LItem.AsInstance is TInject then
    begin
      Result := TInject(LItem.AsInstance).GetTry<T>(ATag);
      if Result <> nil then
      begin
        _Log('Service resolved from child injector: ' + LTag);
        Exit;
      end;
    end;
  end;

  // Se chegou até aqui, o serviço não foi encontrado
  _Log('Service not found: ' + LTag);
  raise EServiceNotFound.Create(Format('Service %s not found!', [LTag]));
end;

function TInject.GetInterface<I>(const ATag: string): I;
var
  LItem: TServiceData;
  LGuid: TGUID;
  LGuidstring: string;
begin
  LGuid := GetTypeData(TypeInfo(I)).Guid;
  LGuidstring := GUIDTostring(LGuid);
  if ATag <> '' then
    LGuidstring := ATag;
  _LogOperation('Get Interface', LGuidstring);

  Result := GetInterfaceTry<I>(ATag);
  if Result <> nil then
  begin
    _Log('Interface resolved: ' + LGuidstring);
    Exit;
  end;

  for LItem in GetInstances.Values do
  begin
    if LItem.AsInstance is TInject then
    begin
      Result := TInject(LItem.AsInstance).GetInterfaceTry<I>(ATag);
      if Result <> nil then
      begin
        _Log('Interface resolved from child injector: ' + LGuidstring);
        Exit;
      end;
    end;
  end;

  // Se chegou até aqui, a interface não foi encontrada
  _Log('Interface not found: ' + LGuidstring);
  raise EServiceNotFound.Create(Format('Interface %s not found!', [LGuidstring]));
end;

function TInject.GetTry<T>(const ATag: string): T;
var
  LValue: TServiceData;
  LParams: TConstructorParams;
  LTag: string;
begin
  Result := nil;
  LTag := ATag;
  if LTag = '' then
    LTag := T.ClassName;
  if not FRepositoryReference.ContainsKey(LTag) then
    Exit;

  // Verificar dependência circular
  _PushDependency(LTag);
  try
    // Lazy
    LParams := [];
    if not FInstances.ContainsKey(LTag) then
    begin
      LValue := FInjectorFactory.FactorySingleton<T>;
      FInstances.Add(LTag, LValue);
    end;
    if (FInstances.Items[LTag].AsInstance = nil) and (FInjectorEvents.Count = 0) then
      LParams := _ResolverParams(FInstances.Items[LTag].ServiceClass);
    Result := FInstances.Items[LTag].GetInstance<T>(FInjectorEvents, LParams);
  finally
    _PopDependency;
  end;
end;

function TInject.GetInterfaceTry<I>(const ATag: string): I;
var
  LServiceData: TServiceData;
  LParams: TConstructorParams;
  LGuid: TGUID;
  LGuidstring: string;
  LKey: TClass;
  LValue: TGUID;
begin
  Result := nil;
  LGuid := GetTypeData(TypeInfo(I)).Guid;
  LGuidstring := GUIDTostring(LGuid);
  if ATag <> '' then
    LGuidstring := ATag;
  if not FRepositoryInterface.ContainsKey(LGuidstring) then
    Exit;

  // Verificar dependência circular
  _PushDependency(LGuidstring);
  try
    // SingletonLazy
    LParams := [];
    if not FInstances.ContainsKey(LGuidstring) then
    begin
      LKey := FRepositoryInterface.Items[LGuidstring].Key;
      LValue := FRepositoryInterface.Items[LGuidstring].Value;
      LServiceData := FInjectorFactory.FactoryInterface<I>(LKey, LValue);
      FInstances.Add(LGuidstring, LServiceData);
    end;
    if (FInstances.Items[LGuidstring].AsInstance = nil) and (FInjectorEvents.Count = 0) then
      LParams := _ResolverParams(FInstances.Items[LGuidstring].ServiceClass);
    Result := FInstances.Items[LGuidstring].GetInterface<I>(LGuidstring, FInjectorEvents, LParams);
  finally
    _PopDependency;
  end;
end;

procedure TInject.Remove<T>(const ATag: string);
var
  LTag: string;
  LOnDestroy: TProc<T>;
begin
  LTag := ATag;
  if LTag = '' then
    LTag := T.ClassName;
  // OnDestroy
  if FInjectorEvents.ContainsKey(LTag) then
  begin
    LOnDestroy := TProc<T>(FInjectorEvents.Items[LTag].OnDestroy);
    if Assigned(LOnDestroy) then
      LOnDestroy(T(FInstances.Items[LTag].AsInstance));
  end;
  if FRepositoryReference.ContainsKey(LTag) then
    FRepositoryReference.Remove(LTag);
  if FRepositoryInterface.ContainsKey(LTag) then
    FRepositoryInterface.Remove(LTag);
  if FInjectorEvents.ContainsKey(LTag) then
    FInjectorEvents.Remove(LTag);
  if FInstances.ContainsKey(LTag) then
    FInstances.Remove(LTag);
end;

procedure TInject._AddEvents<T>(const AClassName: string;
  const AOnCreate: TProc<T>;
  const AOnDestroy: TProc<T>;
  const AOnConstructorParams: TConstructorCallback);
var
  LEvents: TInjectEvents;
begin
  if (not Assigned(AOnDestroy)) and (not Assigned(AOnCreate)) and
     (not Assigned(AOnConstructorParams)) then
    Exit;
  if FInjectorEvents.ContainsKey(AClassname) then
    Exit;
  LEvents := TInjectEvents.Create;
  LEvents.OnDestroy := TProc<TObject>(AOnDestroy);
  LEvents.OnCreate := TProc<TObject>(AOnCreate);
  LEvents.OnParams := AOnConstructorParams;
  //
  FInjectorEvents.AddOrSetValue(AClassname, LEvents);
end;

function TInject._ResolverParams(const AClass: TClass): TConstructorParams;

  function TostringParams(const AValues: TArray<TValue>): string;
  var
    LIndex: Integer;
  begin
    Result := '';
    for LIndex := 0 to High(AValues) do
    begin
      Result := Result + AValues[LIndex].Tostring;
      if LIndex < High(AValues) then
        Result := Result + ', ';
    end;
  end;

var
  LRttiType: TRttiType;
  LRttiMethod: TRttiMethod;
  LParameter: TRttiParameter;
  LParameterType: TRttiType;
  LInterfaceType: TRttiInterfaceType;
  LParameters: TArray<TRttiParameter>;
  LParameterValues: TArray<TValue>;
  LFor: Integer;
begin
  Result := [];
  // Usar cache RTTI para melhor performance
  LRttiType := _GetCachedType(AClass.ClassName);
  if not Assigned(LRttiType) then
    exit;
  LRttiMethod := _GetCachedMethod(AClass.ClassName, 'Create');
  if not Assigned(LRttiMethod) then
    exit;
  LParameters := LRttiMethod.GetParameters;
  SetLength(LParameterValues, Length(LParameters));
  try
    for LFor := 0 to High(LParameters) do
    begin
      LParameter := LParameters[LFor];
      LParameterType := LParameter.ParamType;
      case LParameterType.TypeKind of
        tkClass, tkClassRef:
        begin
          LParameterValues[LFor] := TValue.From(Get<TObject>(string(LParameterType.Handle.Name)))
                                          .Cast(LParameterType.Handle);
        end;
        tkInterface:
        begin
          LInterfaceType := FRttiContext.GetType(LParameterType.Handle) as TRttiInterfaceType;
          LParameterValues[LFor] := _ResolverInterfaceType(LParameterType.Handle,
                                                           LInterfaceType.GUID);
        end;
        else
          LParameterValues[LFor] := TValue.From(nil);
      end;
    end;
  except
    on E: Exception do
      raise Exception.Create(E.Message + ' => ' + TostringParams(LParameterValues));
  end;
  Result := LParameterValues;
end;

function TInject._ResolverInterfaceType(const AHandle: PTypeInfo;
  const AGUID: TGUID): TValue;
var
  LValue: TValue;
  LResult: TValue;
  LInterface: IInterface;
begin
  Result := TValue.From(nil);
  LValue := TValue.From(GetInterface<IInterface>(GUIDTostring(AGUID)));
  if Supports(LValue.AsInterface, AGUID, LInterface) then
  begin
    TValue.Make(@LInterface, AHandle, LResult);
    Result := LResult;
  end;
end;

procedure TInject._CheckCircularDependency(const AServiceName: string);
var
  LFor: Integer;
  LDep: Integer;
  LDependencyChain: string;
begin
  if not Assigned(FDependencyStack) then
    Exit;

  // Check if the service already exists in the dependency stack
  for LFor := 0 to FDependencyStack.Count - 1 do
  begin
    if FDependencyStack[LFor] = AServiceName then
    begin
      // Build the dependency chain for the error message, only up to the detected cycle
      LDependencyChain := '';
      for LDep := 0 to LFor do
      begin
        LDependencyChain := LDependencyChain + FDependencyStack[LDep];
        if LDep < LFor then
          LDependencyChain := LDependencyChain + ' -> ';
      end;
      // Add the current service again to close the cycle
      LDependencyChain := LDependencyChain + ' -> ' + AServiceName;

      raise ECircularDependency.Create(
        Format('Circular dependency detected: %s', [LDependencyChain])
      );
    end;
  end;
end;

procedure TInject._PushDependency(const AServiceName: string);
begin
  if not Assigned(FDependencyStack) then
    FDependencyStack := TList<string>.Create;

  _CheckCircularDependency(AServiceName);
  FDependencyStack.Add(AServiceName);
end;

procedure TInject._PopDependency;
begin
  if Assigned(FDependencyStack) and (FDependencyStack.Count > 0) then
    FDependencyStack.Delete(FDependencyStack.Count - 1);
end;

function TInject._GetCachedType(const AClassName: string): TRttiType;
begin
  Result := nil;
  if not Assigned(FRttiCacheLock) then
    Exit;

  FRttiCacheLock.Enter;
  try
    if FTypeCache.ContainsKey(AClassName) then
      Result := FTypeCache[AClassName]
    else
    begin
      Result := FRttiContext.FindType(AClassName);
      if Assigned(Result) then
        FTypeCache.Add(AClassName, Result);
    end;
  finally
    FRttiCacheLock.Leave;
  end;
end;

function TInject._GetCachedMethod(const AClassName, AMethodName: string): TRttiMethod;
var
  LKey: string;
  LRttiType: TRttiType;
begin
  Result := nil;
  if not Assigned(FRttiCacheLock) then
    Exit;

  LKey := AClassName + '.' + AMethodName;
  FRttiCacheLock.Enter;
  try
    if FMethodCache.ContainsKey(LKey) then
      Result := FMethodCache[LKey]
    else
    begin
      LRttiType := _GetCachedType(AClassName);
      if Assigned(LRttiType) then
      begin
        Result := LRttiType.GetMethod(AMethodName);
        if Assigned(Result) then
          FMethodCache.Add(LKey, Result);
      end;
    end;
  finally
    FRttiCacheLock.Leave;
  end;
end;

procedure TInject._ClearRttiCache;
begin
  if not Assigned(FRttiCacheLock) then
    Exit;

  FRttiCacheLock.Enter;
  try
    if Assigned(FTypeCache) then
      FTypeCache.Clear;
    if Assigned(FMethodCache) then
      FMethodCache.Clear;
  finally
    FRttiCacheLock.Leave;
  end;
end;

procedure TInject._Log(const AMessage: string);
begin
  if FLoggingEnabled and Assigned(FLogCallback) then
    FLogCallback(Format('[Injector4D] %s - %s', [FormatDateTime('hh:nn:ss.zzz', Now), AMessage]));
end;

procedure TInject._LogOperation(const AOperation, AServiceName: string);
begin
  if FLoggingEnabled then
    _Log(Format('%s: %s', [AOperation, AServiceName]));
end;

procedure TInject.EnableLogging(const ALogCallback: TProc<string>);
begin
  FLoggingEnabled := True;
  FLogCallback := ALogCallback;
  _Log('Logging enabled');
end;

procedure TInject.DisableLogging;
begin
  if FLoggingEnabled then
    _Log('Logging disabled');
  FLoggingEnabled := False;
  FLogCallback := nil;
end;

procedure TInject.ClearCache;
begin
  _Log('Clearing RTTI cache');
  _ClearRttiCache;
end;

initialization
  GInjectorLock := TCriticalSection.Create;
  New(GPInjector);
  GPInjector^ := TInject.Create;

finalization
  if Assigned(GInjectorLock) then
  begin
    GInjectorLock.Enter;
    try
      if Assigned(GPInjector) then
      begin
        GPInjector^.Free;
        Dispose(GPInjector);
        GPInjector := nil;
      end;
    finally
      GInjectorLock.Leave;
      GInjectorLock.Free;
      GInjectorLock := nil;
    end;
  end;

end.


