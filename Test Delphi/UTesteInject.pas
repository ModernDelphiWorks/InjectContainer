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

unit UTesteInject;

interface

uses
  Rtti,
  TypInfo,
  SysUtils,
  DUnitX.TestFramework;

type
  TFake = System.TInterfacedObject;

  IMyClass = Interface
    ['{62A5DFDB-ADA7-4DDA-8524-1CA04242E9F5}']
    function GetMessage: String;
  end;

  TMyClass = class(TInterfacedObject, IMyClass)
  public
    function GetMessage: String;
  end;

  // Testar Auto Inject
  IParamClass = Interface
    ['{6A1154CC-51D2-47BE-8B19-4C949D6A5881}']
    function GetMessage: String;
  end;

  TParamClass = class(TInterfacedObject, IParamClass)
  public
    function GetMessage: String;
  end;

  TMyClassParam = class
  private
    FClass: TParamClass;
    FInterface: IParamClass;
  public
    constructor Create(const AClass: TParamClass;
                       const AInterface: IParamClass);
    property ParamClass: TParamClass read FClass;
    property ParamInterface: IParamClass read FInterface;
  end;

  [TestFixture]
  TTestInjector = class(TObject)
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure TestInjectorSington;
    [Test]
    procedure TestInjectorLazyLoad;
    [Test]
    procedure TestInjectorFactory;
    [Test]
    procedure TestInjectorInterface;
    [Test]
    procedure TestInjectorInterfaceTag;
    [Test]
    procedure TestInjectorInterfaceRefCountEqualOne;
    [Test]
    procedure TestInjectorInterfaceRefCountEqualTo;
    [Test]
    procedure TestInjectorInterfaceGetMessage;
    [Test]
    procedure TestInjectorAutoInjectParams;
    [Test]
    procedure TestConcurrentResolveIsThreadSafe;
  end;

implementation

uses
  Classes,
  SyncObjs,
  Generics.Collections,
  Inject;

type
  // Serviços simples usados só pelo teste de concorrência.
  TCLeafA = class end;
  TCLeafB = class end;
  TCLeafC = class end;
  TCLeafD = class end;
  TCLeafE = class end;

  TResolveWorker = class(TThread)
  private
    FInjector: TInject;
    FGate: TEvent;
    FGets: Integer;
    FFailures: PInteger;
    FFirstError: PString;
    FErrLock: TCriticalSection;
  protected
    procedure Execute; override;
  public
    constructor Create(AInjector: TInject; AGate: TEvent; AGets: Integer;
      AFailures: PInteger; AFirstError: PString; AErrLock: TCriticalSection);
  end;

constructor TResolveWorker.Create(AInjector: TInject; AGate: TEvent;
  AGets: Integer; AFailures: PInteger; AFirstError: PString;
  AErrLock: TCriticalSection);
begin
  FInjector := AInjector;
  FGate := AGate;
  FGets := AGets;
  FFailures := AFailures;
  FFirstError := AFirstError;
  FErrLock := AErrLock;
  inherited Create(False);
end;

procedure TResolveWorker.Execute;
var
  I: Integer;
begin
  FGate.WaitFor(INFINITE);
  for I := 0 to FGets - 1 do
  begin
    try
      case I mod 5 of
        0: FInjector.Get<TCLeafA>;
        1: FInjector.Get<TCLeafB>;
        2: FInjector.Get<TCLeafC>;
        3: FInjector.Get<TCLeafD>;
      else
        FInjector.Get<TCLeafE>;
      end;
    except
      on E: Exception do
      begin
        TInterlocked.Increment(FFailures^);
        FErrLock.Enter;
        try
          if FFirstError^ = '' then
            FFirstError^ := E.ClassName + ': ' + E.Message;
        finally
          FErrLock.Leave;
        end;
      end;
    end;
  end;
end;

procedure TTestInjector.Setup;
begin

end;

procedure TTestInjector.TearDown;
begin

end;

procedure TTestInjector.TestInjectorFactory;
var
  LMyClass1: TMyClass;
  LMyClass2: TMyClass;
  LInjector: TInject;
begin
  LInjector := TInject.Create;
  try
    LInjector.Factory<TMyClass>;

    LMyCLass1 := LInjector.Get<TMyClass>;
    LMyCLass2 := LInjector.Get<TMyClass>;

    Assert.AreNotEqual(LMyClass1, LMyClass2, 'equal objects' );
  finally
    LInjector.Free;
  end;
end;

procedure TTestInjector.TestInjectorInterface;
var
  LMyClass1: IMyClass;
  LMyClass2: IMyClass;
  LInjector: TInject;
begin
  LInjector := TInject.Create;
  try
    LInjector.SingletonInterface<IMyClass, TMyClass>;

    LMyCLass1 := LInjector.GetInterface<IMyClass>;
    LMyCLass2 := LInjector.GetInterface<IMyClass>;

    Assert.AreEqual(LMyClass1, LMyClass2, '(MyClass1 <> MyClass2)' );
    Assert.AreEqual(TFake(LMyClass1).RefCount, TFake(LMyClass2).RefCount, '(MyClass1.RefCount <> MyClass2.RefCount)' );
  finally
    LInjector.Free;
  end;
end;

procedure TTestInjector.TestInjectorInterfaceGetMessage;
var
  LMyClass1: IMyClass;
  LInjector: TInject;
begin
  LInjector := TInject.Create;
  try
    LInjector.SingletonInterface<IMyClass, TMyClass>;

    LMyCLass1 := LInjector.GetInterface<IMyClass>;
    Assert.AreEqual(LMyClass1.GetMessage, 'TMyClass Message!', '(Message <> TMyClass Message!)' );
  finally
    LInjector.Free;
  end;
end;

procedure TTestInjector.TestInjectorInterfaceTag;
var
  LMyClass1: IMyClass;
  LMyClass2: IMyClass;
  LInjector: TInject;
begin
  LInjector := TInject.Create;
  try
    LInjector.SingletonInterface<IMyClass, TMyClass>('TMyClass');

    LMyCLass1 := LInjector.GetInterface<IMyClass>('TMyClass');
    LMyCLass2 := LInjector.GetInterface<IMyClass>('TMyClass');

    Assert.AreEqual(LMyClass1, LMyClass2, '(LMyClass1 <> LMyClass2)' );
  finally
    LInjector.Free;
  end;
end;

procedure TTestInjector.TestInjectorInterfaceRefCountEqualTo;
var
  LMyClass1: IMyClass;
  LMyClass2: IMyClass;
  LInjector: TInject;
begin
  LInjector := TInject.Create;
  try
    LInjector.SingletonInterface<IMyClass, TMyClass>;

    LMyCLass1 := LInjector.GetInterface<IMyClass>;
    LMyCLass2 := LInjector.GetInterface<IMyClass>;

    Assert.AreEqual(TFake(LMyClass1).RefCount, 2, 'MyClass1.RefCount <> 2' );
  finally
    LInjector.Free;
  end;
end;

procedure TTestInjector.TestInjectorInterfaceRefCountEqualOne;
var
  LMyClass1: IMyClass;
  LInjector: TInject;
begin
  LInjector := TInject.Create;
  try
    LInjector.SingletonInterface<IMyClass, TMyClass>;

    LMyCLass1 := LInjector.GetInterface<IMyClass>;
    Assert.AreEqual(TFake(LMyClass1).RefCount, 1, 'MyClass1.RefCount <> 1' );
  finally
    LInjector.Free;
  end;
end;

procedure TTestInjector.TestInjectorLazyLoad;
var
  LMyClass1: TMyClass;
  LMyClass2: TMyClass;
  LInjector: TInject;
begin
  LInjector := TInject.Create;
  try
    LInjector.SingletonLazy<TMyClass>;

    LMyCLass1 := LInjector.Get<TMyClass>;
    LMyCLass2 := LInjector.Get<TMyClass>;

    Assert.AreEqual(LMyClass1, LMyClass2, 'LMyClass1 <> LMyClass2');
  finally
    LInjector.Free;
  end;
end;

procedure TTestInjector.TestInjectorAutoInjectParams;
var
  LParamClass: TParamClass;
  LParamInterface: IParamClass;
  LMyClassParam: TMyClassParam;
  LMyClassParam1: TMyClassParam;
  LInjector: TInject;
begin
  LInjector := TInject.Create;
  try
    LInjector.Singleton<TParamClass>;
    LInjector.SingletonInterface<IParamClass, TParamClass>;
    // TMyClassParam.Create(const AClass: TParamClass; const AInterface: IParamClass);
    LInjector.Singleton<TMyClassParam>;
    // Auto Inject Params
    LMyClassParam := LInjector.Get<TMyClassParam>;

    Assert.IsNotNull(LMyClassParam.ParamClass, 'ParamClass is nil');
    Assert.IsNotNull(LMyClassParam.ParamInterface, 'ParamInterface is nil');
  finally
    LInjector.Free;
  end;
end;

procedure TTestInjector.TestConcurrentResolveIsThreadSafe;
const
  THREADS = 8;
  ROUNDS  = 10;
  GETS    = 20000;
var
  LInjector: TInject;
  LGate: TEvent;
  LErrLock: TCriticalSection;
  LWorkers: array[0..THREADS - 1] of TResolveWorker;
  LFailures: Integer;
  LFirstError: string;
  I: Integer;
  R: Integer;
begin
  // Regressão da correção de thread-safety da pilha de resolução (PR#307):
  // resolves concorrentes NÃO podem gerar falso "Circular dependency detected"
  // nem corromper a TList da pilha (range error / AV).
  LFailures := 0;
  LFirstError := '';
  LInjector := TInject.Create;
  LErrLock := TCriticalSection.Create;
  try
    LInjector.Singleton<TCLeafA>;
    LInjector.Singleton<TCLeafB>;
    LInjector.Singleton<TCLeafC>;
    LInjector.Singleton<TCLeafD>;
    LInjector.Singleton<TCLeafE>;
    // Pré-instancia no thread principal: durante a fase concorrente FInstances
    // é só lido e a pilha de dependências é o único estado mutável sob teste.
    LInjector.Get<TCLeafA>;
    LInjector.Get<TCLeafB>;
    LInjector.Get<TCLeafC>;
    LInjector.Get<TCLeafD>;
    LInjector.Get<TCLeafE>;

    for R := 1 to ROUNDS do
    begin
      LGate := TEvent.Create(nil, True, False, '');
      try
        for I := 0 to THREADS - 1 do
          LWorkers[I] := TResolveWorker.Create(LInjector, LGate, GETS,
            @LFailures, @LFirstError, LErrLock);
        LGate.SetEvent;
        for I := 0 to THREADS - 1 do
        begin
          LWorkers[I].WaitFor;
          LWorkers[I].Free;
        end;
      finally
        LGate.Free;
      end;
      if LFailures > 0 then
        Break;
    end;

    Assert.AreEqual(0, LFailures,
      Format('Concurrent resolve produced %d failure(s). First: %s',
        [LFailures, LFirstError]));
  finally
    LInjector.Free;
    LErrLock.Free;
  end;
end;

procedure TTestInjector.TestInjectorSington;
var
  LMyClass1: TMyClass;
  LMyClass2: TMyClass;
  LInjector: TInject;
begin
  LInjector := TInject.Create;
  try
    LInjector.Singleton<TMyClass>;

    LMyCLass1 := LInjector.Get<TMyClass>;
    LMyCLass2 := LInjector.Get<TMyClass>;

    Assert.AreEqual(LMyClass1, LMyClass2, 'LMyClass1 <> LMyClass2' );
  finally
    LInjector.Free;
  end;
end;

{ TMyClass }

function TMyClass.GetMessage: String;
begin
  Result := 'TMyClass Message!';
end;

{ TMyClassParam }

constructor TMyClassParam.Create(const AClass: TParamClass;
  const AInterface: IParamClass);
var
  L1: String;
  L2: String;
begin
  FClass := AClass;
  FInterface := AInterface;
  L1 := FClass.GetMessage;
  L2 := FInterface.GetMessage;
end;

{ TParamClass }

function TParamClass.GetMessage: String;
begin
  Result := 'TParamClass Message!';
end;

initialization
  TDUnitX.RegisterTestFixture(TTestInjector);
end.
