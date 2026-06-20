---
displayed_sidebar: injectcontainerSidebar
title: Configuration
sidebar_position: 2
---

InjectContainer has no configuration file or fluent builder for container options. Configuration is performed through code at registration time and through the two optional runtime toggles described below.

## Logging

| API | Default | Effect |
|---|---|---|
| `EnableLogging(nil)` | Off | Generates log strings but delivers to no sink |
| `EnableLogging(proc)` | Off | Delivers log strings to `proc` on every operation |
| `DisableLogging` | — | Turns off log generation entirely |

```pascal
// Wire to any string sink
GetInjector.EnableLogging(
  procedure(const AMsg: string)
  begin
    TLogger.Write(AMsg);
  end
);
```

## RTTI cache

The cache is **always active** — there is no option to disable it. The only control is `ClearCache`, which forces a full eviction of the type and method dictionaries. Call it if you dynamically load/unload packages.

```pascal
GetInjector.ClearCache;
```

## Boss / PubPascal manifest (`boss.json` / `pubpascal.json`)

The only build-time configuration is the standard package manifest at the repository root. No framework-specific options are read from these files at runtime.

```json
// boss.json (example)
{
  "name": "injectcontainer",
  "version": "1.0.0",
  "homepage": "https://github.com/ModernDelphiWorks/InjectContainer"
}
```

## Search path (Delphi project)

Add only the `Source` folder — there is no sub-folder distinction needed:

```
<install-root>\InjectContainer\Source
```

All six units (`Inject`, `Inject.Container`, `Inject.Factory`, `Inject.Service`, `Inject.Events`, `Inject.Service.Abstract`) are in `Source\` directly; no sub-path is required.

## Compiler defines

InjectContainer uses no `{$DEFINE}` switches and requires no conditional compilation. It was verified to compile clean for **Win32, Win64, and Linux64** without any `{$IFDEF MSWINDOWS}` or similar guards.

## Delphi version support

Minimum: **Delphi XE** (requires `System.Rtti`, `System.Generics.Collections`, `System.SyncObjs`, `System.TypInfo`). All units are in the `System.` namespace, available since Delphi XE.
