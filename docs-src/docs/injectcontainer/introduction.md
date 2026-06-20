---
displayed_sidebar: injectcontainerSidebar
title: Introduction
sidebar_position: 2
---

## What is InjectContainer?

**InjectContainer** is a state-of-the-art Dependency Injection (DI) framework for Delphi (XE or higher). It manages object lifecycles — Singleton, Factory, LazyLoad, and Interface-to-class mappings — in a single thread-safe container backed by a high-speed RTTI metadata cache.

## Problem it solves

In traditional Delphi applications, each form or controller creates its own service instances directly, scattering `TMyService.Create` calls throughout the codebase. This pattern:

- makes unit testing difficult (no substitution point),
- hides dependencies inside implementation bodies,
- spreads lifetime management across many owners,
- creates implicit coupling between concrete classes.

InjectContainer replaces ad-hoc construction with a single registration/resolution contract: you declare what each service _is_ (lifecycle + type), and consumers ask for it by type or interface — never by creating it directly.

## Key features

| Feature | Detail |
|---|---|
| **Singleton** | One shared instance for the entire application lifetime |
| **Factory** | A new instance on every resolution call |
| **LazyLoad (SingletonLazy)** | Singleton, but constructed only when first requested |
| **Interface binding** | Maps `IMyInterface` → `TMyImpl`; resolves via GUID |
| **100% thread-safe** | All registration and resolution paths are guarded by a `TCriticalSection` |
| **RTTI cache** | `TDictionary`-backed type and method cache; 40–60% faster than raw RTTI |
| **Circular dependency detection** | Stack-based push/pop; raises `ECircularDependency` with the full chain |
| **Lifecycle logging** | Optional `TProc<string>` callback traces creation, resolution, and destruction |
| **Memory pool** | Instance pooling reduces heap pressure 20–30% for high-frequency Factory calls |
| **Child injectors** | Compose multiple `TInject` containers; resolution cascades to child injectors |

## Who is it for?

- Delphi developers building enterprise applications (VCL, FMX, or console servers).
- Teams that need testable, modular architectures without heavyweight IoC frameworks.
- Backend services compiled for **Win32, Win64, and Linux64** (verified clean, no platform guards needed).

## Compatibility

| IDE / Environment | Platforms | Thread-Safe | Circular Detection |
|---|---|:---:|:---:|
| Delphi XE or higher | VCL, FMX, Console (Win/Linux/macOS/iOS/Android) | Yes | Yes |

:::note Cross-platform build
InjectContainer is already platform-neutral. It has been build-verified on **Win32, Win64, and Linux64** (`dcclinux64`) with no `{$IFDEF}` guards needed. macOS/iOS/Android follow from the Delphi RTL but have not been build-verified yet.
:::
