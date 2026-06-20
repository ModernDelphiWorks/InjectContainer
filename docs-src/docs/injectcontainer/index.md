---
displayed_sidebar: injectcontainerSidebar
title: InjectContainer
sidebar_position: 1
---

**InjectContainer** is a high-performance, thread-safe Dependency Injection (DI) framework for Delphi. It decouples classes and interfaces dynamically with minimal runtime overhead, using a custom RTTI cache, object instantiation pooling, and automatic circular dependency detection.

## Where to start

- [Introduction](introduction.md)
- [Installation](getting-started/installation.md)
- [Quickstart](getting-started/quickstart.md)
- [API Reference](reference/api.md)
- [Troubleshooting](troubleshooting/common-errors.md)

## Guides

- [Registering Singletons](guides/singleton.md)
- [Registering Factories](guides/factory.md)
- [Lazy Load](guides/lazy-load.md)
- [Interface Binding](guides/interface-binding.md)
- [Resolving Dependencies](guides/resolving-dependencies.md)
- [Events & Logging](guides/events-and-logging.md)
- [Child Injectors](guides/child-injectors.md)

## Architecture

- [Overview](architecture/overview.md)
- [RTTI Cache](architecture/rtti-cache.md)
- [Thread Safety](architecture/thread-safety.md)
- [Circular Dependency Detection](architecture/circular-dependency.md)

## Scope

**Covers:** DI lifecycle management (Singleton, Factory, LazyLoad, Interface-to-class), thread-safe container, RTTI cache, circular dependency detection, lifecycle logging, child injectors, and instance pooling for Delphi XE or higher across Win32 / Win64 / Linux64.

**Does not cover:** IoC container wiring via attributes/annotations, AOP interception, or HTTP/framework middleware — InjectContainer is a pure DI kernel.
