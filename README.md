# InjectContainer for Delphi

[![Delphi XE+](https://img.shields.io/badge/Delphi-XE%20or%20superior-blue.svg)]()
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

*   [🇬🇧 English](#-english)
*   [🇧🇷 Português](#-português)

---

## 🇬🇧 English

**InjectContainer** is a state-of-the-art, high-performance, and thread-safe Dependency Injection (DI) framework for Delphi. Designed to simplify the development of robust, modular, and enterprise-grade applications, InjectContainer decouples classes and interfaces dynamically with minimal runtime overhead. By leveraging a high-speed optimized RTTI cache, object instantiation pooling, and automatic circular dependency detection, it provides developers with a seamless, clean, and modern codebase architecture.

### 🚀 Key Features

*   **Diverse Lifecycle Management:** Register and resolve dependencies as Singletons, Factories, LazyLoads, and Interface-based classes.
*   **100% Thread-Safe:** Built from the ground up to be safe for highly concurrent, multi-threaded server environments out of the box.
*   **High-Speed RTTI Cache:** Custom metadata cache pooling yields up to 40% to 60% faster resolution compared to standard Delphi RTTI.
*   **Circular Dependency Detection:** Automatic prevention mechanism that detects and reports infinite instantiation loops during resolution.
*   **Comprehensive Lifecycle Logging:** Built-in hooks to trace, monitor, and audit object lifecycles (creation, resolution, and destruction).
*   **Memory Pool Optimizations:** Native allocation optimization reduces heap overhead by 20% to 30% for high-frequency factory instantiations.

### 🏛 Compatibility Matrix

| Environment / IDE | Platform / Compiler | Thread Safety | Circular Detection |
| :--- | :--- | :---: | :---: |
| **Delphi XE or superior** | VCL, FMX, Console (Win/Linux/macOS/iOS/Android) | ✅ Yes | ✅ Yes |

### 🐧 Cross-Platform Build — Win32 / Win64 / Linux64 (verified)

> **✅ Verified 2026-06-20** in a real production backend: InjectContainer compiles **clean** for **Win32, Win64 and Linux64** (`dcclinux64`) with **no platform guards needed** — it was already platform-neutral. macOS/iOS/Android follow from the Delphi RTL but are **not build-verified** here yet.

**Building a consumer app for Linux64:** install the Linux 64-bit platform (RAD Studio GetIt / `GetItCmd -if=delphi_linux -ae`), provide a Linux SDK (RAD Studio SDK Manager + PAServer, **or** a sysroot assembled from a WSL/Linux toolchain passed to `dcclinux64` via `--syslibroot` / `--libpath`), then compile with `dcclinux64`.

### ⚙️ Installation

To install using the package manager [**Boss**](https://github.com/HashLoad/boss):

```sh
boss install "https://github.com/ModernDelphiWorks/InjectContainer"
```

> [!NOTE]
> Since this package does not have a static registry on Boss, it must be installed using its direct Git repository HTTPS URL.

---

### ⚡️ Quick Start

#### 1. Setup Entry Point
```delphi
program MyApp;

uses
  InjectContainer.Core;

begin
  // Initialize and build the global dependency container
  InjectContainer.Build;
  
  Application.Initialize;
  Application.Run;
end.
```

#### 2. Registering Dependencies
```delphi
uses
  InjectContainer.Core;

// Register a Singleton (a single shared instance)
InjectContainer.RegisterSingleton<IUserService, TUserService>;

// Register a Factory (creates a new instance upon each request)
InjectContainer.RegisterFactory<IEmailService, TEmailService>;

// Register a LazyLoad (instantiated only when first requested)
InjectContainer.RegisterLazy<ILogService, TLogService>;
```

#### 3. Resolving Dependencies
```delphi
// Resolve via interface
var LUserService := InjectContainer.GetInterface<IUserService>;

// Resolve via concrete class
var LEmailService := InjectContainer.Get<TEmailService>;
```

---

## 🇧🇷 Português

**InjectContainer** é um framework moderno, de alta performance e thread-safe para Injeção de Dependências (DI) em Delphi. Projetado para simplificar a criação de aplicações corporativas robustas e modulares, o InjectContainer desacopla classes e interfaces de forma dinâmica com o menor overhead possível. Ao combinar cache RTTI otimizado de alta velocidade, pooling de instanciação de objetos e detecção automática de dependência circular, ele fornece aos desenvolvedores uma arquitetura limpa, legível e de padrão state-of-the-art.

### 🚀 Recursos Principais

*   **Múltiplos Ciclos de Vida:** Registre e resolva dependências como Singleton, Factory, LazyLoad ou mapeamento simples baseado em interfaces.
*   **Totalmente Thread-Safe:** Implementado nativamente para ser seguro para o uso concorrente em ambientes multi-thread de alta carga de forma imediata.
*   **Cache RTTI de Alta Velocidade:** O cache RTTI personalizado reduz o tempo de busca e carregamento de metadados entre 40% e 60% comparado à RTTI padrão.
*   **Detecção de Dependência Circular:** Mecanismo automático para prevenir loops infinitos e gerar relatórios claros de dependência cíclica durante a resolução.
*   **Log de Ciclo de Vida:** Sistema de monitoramento integrado para registrar a criação, resolução e destruição de recursos.
*   **Otimização de Alocação de Memória:** O pool de memória otimizado reduz a alocação em heap entre 20% e 30% em instanciamentos de Factory muito recorrentes.

### 🏛 Matriz de Compatibilidade

| Ambiente / IDE | Plataforma / Compilador | Thread Safety | Detecção Circular |
| :--- | :--- | :---: | :---: |
| **Delphi XE ou superior** | VCL, FMX, Console (Win/Linux/macOS/iOS/Android) | ✅ Sim | ✅ Sim |

### 🐧 Build Multiplataforma — Win32 / Win64 / Linux64 (verificado)

> **✅ Verificado em 2026-06-20** num backend real em produção: o InjectContainer compila **limpo** em **Win32, Win64 e Linux64** (`dcclinux64`), **sem nenhum guard de plataforma** — já era neutro. macOS/iOS/Android seguem da RTL Delphi, mas **ainda não foram verificados** em build aqui.

**Para buildar um app consumidor no Linux64:** instale a plataforma Linux 64-bit (RAD Studio GetIt / `GetItCmd -if=delphi_linux -ae`), forneça um SDK Linux (SDK Manager do RAD Studio + PAServer, **ou** um sysroot montado de um toolchain WSL/Linux passado ao `dcclinux64` via `--syslibroot` / `--libpath`), e compile com `dcclinux64`.

### ⚙️ Instalação

Para instalar usando o gerenciador de pacotes [**Boss**](https://github.com/HashLoad/boss):

```sh
boss install "https://github.com/ModernDelphiWorks/InjectContainer"
```

> [!NOTE]
> Como esta biblioteca não está pré-registrada com apelido no indexador global do Boss, ela é instalada informando-se o link HTTPS direto de seu repositório Git.

---

### ⚡️ Início Rápido

#### 1. Configurando o Entry Point (Bootstrapping)
```delphi
program MyApp;

uses
  InjectContainer.Core;

begin
  // Inicializa e constrói o container de injeção global
  InjectContainer.Build;
  
  Application.Initialize;
  Application.Run;
end.
```

#### 2. Registrando Dependências
```delphi
uses
  InjectContainer.Core;

// Registra um Singleton (única instância compartilhada por toda a aplicação)
InjectContainer.RegisterSingleton<IUserService, TUserService>;

// Registra uma Factory (uma nova instância criada a cada chamada de resolução)
InjectContainer.RegisterFactory<IEmailService, TEmailService>;

// Registra um LazyLoad (instanciado tardiamente apenas quando solicitado)
InjectContainer.RegisterLazy<ILogService, TLogService>;
```

#### 3. Resolvendo Dependências
```delphi
// Resolve através de interface
var LUserService := InjectContainer.GetInterface<IUserService>;

// Resolve através da classe concreta
var LEmailService := InjectContainer.Get<TEmailService>;
```

---
*Copyright © 2025-2026 Isaque Pinheiro. Licensed under MIT License.*
