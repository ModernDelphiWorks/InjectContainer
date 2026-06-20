---
displayed_sidebar: injectcontainerSidebar
title: Circular Dependency Detection
sidebar_position: 4
---

InjectContainer automatically detects and reports circular dependencies during resolution, preventing infinite instantiation loops and stack overflows.

## How it works

`TInject` maintains a `FDependencyStack: TList<string>` that tracks the chain of services being resolved at any point in time.

Every call to `GetTry<T>` or `GetInterfaceTry<I>` wraps resolution in a push/pop pair:

```pascal
_PushDependency(LTag);
try
  // ... resolve the service
finally
  _PopDependency;
end;
```

`_PushDependency` calls `_CheckCircularDependency` before adding the name to the stack:

```pascal
procedure TInject._CheckCircularDependency(const AServiceName: string);
var
  LFor: Integer;
begin
  for LFor := 0 to FDependencyStack.Count - 1 do
  begin
    if FDependencyStack[LFor] = AServiceName then
    begin
      // Build full chain string up to the repeated node
      raise ECircularDependency.Create(
        Format('Circular dependency detected: %s', [LDependencyChain])
      );
    end;
  end;
end;
```

## Error raised

```pascal
ECircularDependency = class(EInjectException);
```

The exception message includes the full chain, e.g.:

```
Circular dependency detected: TServiceA -> TServiceB -> TServiceC -> TServiceA
```

## Example scenario

```pascal
// TServiceA.Create resolves TServiceB
// TServiceB.Create resolves TServiceA  ← circular!

GetInjector.SingletonLazy<TServiceA>;
GetInjector.SingletonLazy<TServiceB>;

try
  var LA := GetInjector.Get<TServiceA>;
except
  on E: ECircularDependency do
    Writeln(E.Message);
    // Circular dependency detected: TServiceA -> TServiceB -> TServiceA
end;
```

## How to fix circular dependencies

Circular dependencies usually signal a design issue. Common fixes:

| Pattern | Fix |
|---|---|
| A → B → A | Extract a shared `C` that both A and B depend on; neither depends on the other |
| Service needs a late reference | Inject a factory `TFunc<IB>` instead of `IB` directly — resolved lazily |
| Infrastructure loop | Use event callbacks (`OnCreate`) to do the second wiring after construction |

## Stack pop on exception

`_PopDependency` is called in the `finally` block, so the stack is always consistent even when `_CheckCircularDependency` raises or when service construction fails for another reason.
