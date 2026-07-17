program ConcurrencyRepro;

{
  ------------------------------------------------------------------------------
  Deterministic thread-safety repro for TInject's dependency-resolution stack.

  Background (backend PR#307): under concurrent resolves from Horse worker
  threads, TInject raised "Circular dependency detected: TNidus -> TNidus" and
  intermittent AV / range errors. Root cause: the single shared
  FDependencyStack: TList<string> is mutated (Add/Delete) by every resolve on
  every thread with no isolation, so:
    - two threads pushing the same service name see each other's entry and
      raise a FALSE ECircularDependency;
    - concurrent TList.Add/Delete corrupts FCount/FItems -> range errors / AV.

  This console harness makes the race deterministic: it pre-instantiates a set
  of singletons (so the ONLY shared mutation during the hot phase is the
  dependency stack), then hammers Get<> from N threads for ROUNDS rounds.

  Expected:
    - UNPATCHED source: FAILS (exit code 1) with false-circular and/or range
      errors, usually within the first few rounds.
    - PATCHED source:   PASSES (exit code 0) across all rounds.
  ------------------------------------------------------------------------------
}

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  System.Classes,
  System.SyncObjs,
  Inject in '..\Source\Inject.pas',
  Inject.Container in '..\Source\Inject.Container.pas',
  Inject.Events in '..\Source\Inject.Events.pas',
  Inject.Factory in '..\Source\Inject.Factory.pas',
  Inject.Service.Abstract in '..\Source\Inject.Service.Abstract.pas',
  Inject.Service in '..\Source\Inject.Service.pas';

const
  THREADS       = 8;
  ROUNDS        = 50;
  GETS_PER_ROUND = 20000;

type
  TLeafA = class end;
  TLeafB = class end;
  TLeafC = class end;
  TLeafD = class end;
  TLeafE = class end;

var
  GInjector: TInject;
  GFailures: Integer = 0;
  GFirstError: string = '';
  GErrLock: TCriticalSection;

procedure RecordError(const AMsg: string);
begin
  TInterlocked.Increment(GFailures);
  GErrLock.Enter;
  try
    if GFirstError = '' then
      GFirstError := AMsg;
  finally
    GErrLock.Leave;
  end;
end;

type
  TResolveThread = class(TThread)
  private
    FStartGate: TEvent;
  protected
    procedure Execute; override;
  public
    constructor Create(AStartGate: TEvent);
  end;

constructor TResolveThread.Create(AStartGate: TEvent);
begin
  FStartGate := AStartGate;
  inherited Create(False);
end;

procedure TResolveThread.Execute;
var
  I: Integer;
begin
  // All threads block here, then are released together to maximize contention.
  FStartGate.WaitFor(INFINITE);
  for I := 0 to GETS_PER_ROUND - 1 do
  begin
    try
      case I mod 5 of
        0: GInjector.Get<TLeafA>;
        1: GInjector.Get<TLeafB>;
        2: GInjector.Get<TLeafC>;
        3: GInjector.Get<TLeafD>;
      else
        GInjector.Get<TLeafE>;
      end;
    except
      on E: Exception do
        RecordError(E.ClassName + ': ' + E.Message);
    end;
  end;
end;

procedure RunRound;
var
  LGate: TEvent;
  LThreads: array[0..THREADS - 1] of TResolveThread;
  I: Integer;
begin
  LGate := TEvent.Create(nil, True, False, '');
  try
    for I := 0 to THREADS - 1 do
      LThreads[I] := TResolveThread.Create(LGate);
    LGate.SetEvent;   // release all threads at once
    for I := 0 to THREADS - 1 do
    begin
      LThreads[I].WaitFor;
      LThreads[I].Free;
    end;
  finally
    LGate.Free;
  end;
end;

var
  R: Integer;
begin
  GErrLock := TCriticalSection.Create;
  GInjector := TInject.Create;
  try
    GInjector.Singleton<TLeafA>;
    GInjector.Singleton<TLeafB>;
    GInjector.Singleton<TLeafC>;
    GInjector.Singleton<TLeafD>;
    GInjector.Singleton<TLeafE>;

    // Pre-instantiate every singleton on the main thread so that, during the
    // concurrent phase, FInstances is only READ and the dependency stack is
    // the sole shared mutable state under test.
    GInjector.Get<TLeafA>;
    GInjector.Get<TLeafB>;
    GInjector.Get<TLeafC>;
    GInjector.Get<TLeafD>;
    GInjector.Get<TLeafE>;

    Writeln(Format('Concurrency repro: %d threads x %d rounds x %d gets',
      [THREADS, ROUNDS, GETS_PER_ROUND]));
    for R := 1 to ROUNDS do
    begin
      RunRound;
      if GFailures > 0 then
      begin
        Writeln(Format('  round %d: FAILURES so far = %d', [R, GFailures]));
        Break;
      end;
    end;

    Writeln;
    if GFailures > 0 then
    begin
      Writeln('RESULT: FAIL  (failures=', GFailures, ')');
      Writeln('First error: ', GFirstError);
      ExitCode := 1;
    end
    else
    begin
      Writeln('RESULT: PASS  (0 failures across all rounds)');
      ExitCode := 0;
    end;
  finally
    GInjector.Free;
    GErrLock.Free;
  end;
end.
