---
displayed_sidebar: injectcontainerSidebar
title: Installation
sidebar_position: 1
---

## Prerequisites

- **Delphi XE or higher** (VCL, FMX, or Console).
- A package manager: **[Boss](https://github.com/HashLoad/boss)** or **[PubPascal](https://github.com/isaquepinheiro/pubpascal)**.

## Install via Boss

Boss does not have a static registry entry for InjectContainer, so install it directly from the GitHub URL:

```bash
boss install "https://github.com/ModernDelphiWorks/InjectContainer"
```

:::note
You must supply the full HTTPS URL — an alias such as `boss install InjectContainer` does **not** work without a registry entry.
:::

## Install via PubPascal

```bash
pubpascal install ModernDelphiWorks/InjectContainer
```

## Clone the repository (contributor / debug)

```bash
git clone https://github.com/ModernDelphiWorks/InjectContainer.git
```

## Add to search path

After installation, add the `Source` directory to your project's Delphi search path:

1. Open **Project → Options → Delphi Compiler → Search path**.
2. Add the path to the `Source` folder inside the cloned/installed package, for example:

```
$(BOSS_MODULES)\InjectContainer\Source
```

or, if cloned manually:

```
C:\libs\InjectContainer\Source
```

## Verify

Add `Inject` to a `uses` clause and confirm the project compiles:

```pascal
uses
  Inject;

begin
  // Access the global injector
  GetInjector.Singleton<TMyService>;
end.
```

If the compiler resolves `TInject` and `GetInjector` without errors, the installation is complete.
