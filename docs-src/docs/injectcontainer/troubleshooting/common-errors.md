---
displayed_sidebar: injectcontainerSidebar
title: Common Errors
sidebar_position: 1
---

## EServiceAlreadyRegistered

**Symptom:** Exception raised at startup or at a call to `Singleton<T>`, `SingletonLazy<T>`, `SingletonInterface<I,T>`, `Factory<T>`, or `AddInject`.

**Message:** `Class <T> registered!` or `Interface <T> already registered!` or `Injector <tag> already registered!`

**Cause:** The same class, interface GUID, or tag was registered more than once. This commonly happens when:
- A unit's `initialization` block is executed multiple times (e.g., loaded from two different BPL packages that both include the unit).
- You have a conditional branch that registers a service on multiple code paths.

**Fix:**
- Guard registrations with `if not FRepositoryReference.ContainsKey(T.ClassName) then ...` in ambiguous paths.
- Use `AddInstance<T>` when you control the construction and want to overwrite an existing registration (but note this also raises if already registered — use `Remove<T>` first if needed).

---

## EServiceNotFound

**Symptom:** Exception raised at `GetInterface<I>`.

**Message:** `Interface <GUID-string> not found!`

**Cause:** `GetInterface<I>` was called before the interface was registered, or the interface `I` does not have a GUID, or the correct unit was not in the `uses` clause causing `initialization` to never run.

**Fix:**
1. Ensure the unit that contains `GetInjector.SingletonInterface<I, T>` is in the `uses` clause of either the `.dpr` or a unit transitively referenced at startup.
2. Confirm the interface `I` has a GUID attribute (`['{...}']`).
3. Use `GetInjector.GetInstances` to inspect what is actually registered.

---

## ECircularDependency

**Symptom:** Exception during `Get<T>` or `GetInterface<I>`.

**Message:** `Circular dependency detected: TServiceA -> TServiceB -> TServiceA`

**Cause:** Two (or more) services depend on each other, forming a cycle. The dependency stack detects this when the same service name appears twice on the stack.

**Fix:** See [Circular Dependency Detection — How to fix](../architecture/circular-dependency.md#how-to-fix-circular-dependencies).

---

## Get&lt;T&gt; returns nil unexpectedly

**Symptom:** `GetInjector.Get<T>` returns `nil` but no exception is raised.

**Cause:** `Get<T>` returns `nil` (not raises) when the service is not found. Either:
- The service was not registered.
- The registration unit's `initialization` block did not execute (unit not referenced in `uses`).
- The tag passed does not match the registration tag.

**Fix:**
1. Add a nil check and log: `if not Assigned(LSvc) then raise Exception.Create('TMyService not registered')`.
2. Confirm the registration unit is in the `uses` clause.
3. Enable logging (`EnableLogging`) and watch for `Get Service:` lines.

---

## RTTI: class has no parameterless Create constructor

**Symptom:** Access violation or RTTI exception during auto-wired lazy resolution.

**Cause:** `_ResolverParams` calls `TRttiType.GetMethod('Create')` and attempts to invoke it with auto-resolved parameters. If the class has no `Create` method visible to RTTI (e.g., inherited from `TInterfacedObject` with no public override), the method may not be found.

**Fix:** Declare an explicit `constructor Create;` in the class so RTTI can locate and invoke it. Alternatively, supply `AOnConstructorParams` to bypass auto-wiring:

```pascal
GetInjector.SingletonLazy<TMyClass>(
  nil, nil,
  function: TConstructorParams
  begin
    Result := []; // no params
  end
);
```

---

## Package-lock.json mismatch (documentation build only)

**Symptom:** `npm ci` fails in the CI workflow with `npm error Invalid: lock file's <package>` errors.

**Cause:** `package.json` was updated but `package-lock.json` was not regenerated.

**Fix:** Run `npm install` locally inside `docs-src/` and commit the updated `package-lock.json`.

---

## Logging shows [Injector4D] prefix instead of [InjectContainer]

**Symptom:** Log messages contain `[Injector4D]` in the prefix.

**Cause:** The `_Log` method in `Inject.pas` uses a hardcoded prefix `'[Injector4D]'`. This is the internal code name; the public framework name is **InjectContainer**.

**Fix:** This is cosmetic only and does not affect functionality. <!-- TODO: confirm if the prefix will be updated in a future release -->
