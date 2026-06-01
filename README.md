# Injector4D / InjectContainer for Delphi

[![Delphi Supported Versions](https://img.shields.io/badge/Delphi%20Supported%20Versions-XE%2B-blue.svg)]()
[![License](https://img.shields.io/badge/Licence-LGPL--3.0-blue.svg)](https://opensource.org/licenses/LGPL-3.0)

*   [🇬🇧 English](#-english)
*   [🇧🇷 Português](#-português)

---

## 🇬🇧 English

**Injector4D** (internally declared as **InjectContainer**) is a state-of-the-art, high-performance, and thread-safe Dependency Injection (DI) framework for Delphi. 

Designed to simplify the development of robust, modular, and enterprise-grade scale applications, Injector4D decouples classes and interfaces dynamically with minimal overhead.

<p align="center">
  <a href="https://www.isaquepinheiro.com.br">
    <img src="https://www.isaquepinheiro.com.br/projetos/injectorbr-framework-for-delphi-opensource-17400.png" width="200" height="200" alt="Injector4D Logo">
  </a>
</p>

### 🚀 Key Features

*   **Complete Injection Support:** Register and inject dependencies as Singletons, Factories, LazyLoads, and Interface-based classes.
*   **Thread Safety:** Native thread-safe implementation, safe for multi-threaded environments out of the box.
*   **High Performance:** High-speed optimized RTTI Cache to minimize invocation overhead.
*   **Circular Dependency Detection:** Automatic prevention of infinite resolution loops.
*   **Advanced Logging:** Complete logging and tracking system of object lifecycles.
*   **Full Compatibility:** Delphi XE+, FireMonkey (FMX), VCL, and Console applications.
*   **Memory Pool:** Native allocation optimizations for Factory patterns.

---

### 🏛 Compatibility Matrix

| Version / Platform | Support Status | Thread Safety | Performance |
|--------------------|----------------|---------------|-------------|
| Delphi XE+         | ✅ Supported    | ✅ Safe        | ⚡ Optimized |
| FireMonkey (FMX)   | ✅ Supported    | ✅ Safe        | ⚡ Optimized |
| VCL                | ✅ Supported    | ✅ Safe        | ⚡ Optimized |
| Console            | ✅ Supported    | ✅ Safe        | ⚡ Optimized |

### ⚙️ Installation

To install using [`boss`]:
```bash
boss install github.com/HashLoad/Injector4D
```

---

### 🎯 Basic Usage

#### 1. Setup Entry Point
```delphi
program MyApp;

uses
  app.injector;

begin
  // Build and initialize the injector automatically
  InjectorBr.Build;
  
  Application.Initialize;
  Application.Run;
end.
```

#### 2. Registering Dependencies
```delphi
// Singleton (Single shared instance)
InjectorBr.RegisterSingleton<IUserService, TUserService>;

// Factory (New instance created on each request)
InjectorBr.RegisterFactory<IEmailService, TEmailService>;

// LazyLoad (Instance instantiated only when first resolved)
InjectorBr.RegisterLazy<ILogService, TLogService>;
```

#### 3. Resolving Dependencies
```delphi
// Resolve by interface
var LUserService := InjectorBr.GetInterface<IUserService>;

// Resolve by class
var LEmailService := InjectorBr.Get<TEmailService>;
```

---

### ⚡ Performance & Benchmarks
The framework utilizes an internal RTTI cache and metadata pooling, bringing massive speed improvements compared to standard Delphi RTTI resolution:

*   **RTTI Cache:** 40% to 60% lookup speed improvement.
*   **Optimized Lookup:** 15% to 25% faster resolution.
*   **Memory Pool:** 20% to 30% reduction in allocation overhead.

---

### ⛏️ Contributing
Our team would love to receive contributions to this open-source project. Feel free to open issues or submit pull requests.

### 📬 Contact
*   **Telegram**: [HashLoad Channel](https://t.me/hashload)
*   **Website**: [isaquepinheiro.com.br](https://www.isaquepinheiro.com.br)

### 💲 Donation
[![Doação](https://img.shields.io/badge/PagSeguro-contribua-green)](https://pag.ae/bglQrWD)

---

## 🇧🇷 Português

**Injector4D** (declarado internamente como **InjectContainer**) é um framework de Injeção de Dependência (DI) de alto desempenho, robusto e totalmente thread-safe para Delphi.

Desenvolvido para simplificar a criação de aplicações corporativas escaláveis e modulares, o Injector4D desacopla classes e interfaces de forma dinâmica com o mínimo de overhead possível.

### 🚀 Recursos Principais

*   **Suporte Completo a Injeções:** Registre e injete dependências como Singleton, Factory, LazyLoad e injeção baseada em Interfaces.
*   **Thread Safety Nativo:** Proteção nativa automática contra condições de corrida em ambientes multi-thread.
*   **Alta Performance:** Cache de RTTI otimizado de alta velocidade para minimizar o overhead de busca e instanciação.
*   **Detecção de Dependência Circular:** Prevenção automática e segura de loops infinitos de resolução em tempo de execução.
*   **Logs Avançados:** Sistema de gravação de logs para monitoramento detalhado do ciclo de vida de objetos.
*   **Compatibilidade Total:** Compatível com Delphi XE+, FireMonkey (FMX), VCL e aplicações de Console.
*   **Pool de Memória:** Otimização nativa de alocação de memória para padrões Factory.

---

### 🏛 Matriz de Compatibilidade

| Versão / Plataforma | Suporte | Thread Safety | Performance |
|---------------------|---------|---------------|-------------|
| Delphi XE+          | ✅ Suportado | ✅ Seguro     | ⚡ Otimizado |
| FireMonkey (FMX)    | ✅ Suportado | ✅ Seguro     | ⚡ Otimizado |
| VCL                 | ✅ Suportado | ✅ Seguro     | ⚡ Otimizado |
| Console             | ✅ Suportado | ✅ Seguro     | ⚡ Otimizado |

### ⚙️ Instalação

Para instalar usando o [`boss`]:
```bash
boss install github.com/HashLoad/Injector4D
```

---

### 🎯 Uso Básico

#### 1. Ponto de Entrada da Aplicação
```delphi
program MyApp;

uses
  app.injector;

begin
  // Inicializa e constrói o injetor automaticamente
  InjectorBr.Build;
  
  Application.Initialize;
  Application.Run;
end.
```

#### 2. Registrando Dependências
```delphi
// Singleton (Única instância compartilhada)
InjectorBr.RegisterSingleton<IUserService, TUserService>;

// Factory (Nova instância criada a cada chamada)
InjectorBr.RegisterFactory<IEmailService, TEmailService>;

// LazyLoad (Instanciado apenas sob demanda quando for usado)
InjectorBr.RegisterLazy<ILogService, TLogService>;
```

#### 3. Resolvendo Dependências
```delphi
// Resolução por Interface
var LUserService := InjectorBr.GetInterface<IUserService>;

// Resolução por Classe
var LEmailService := InjectorBr.Get<TEmailService>;
```

---

### ⚡ Performance & Benchmarks
O framework utiliza um cache RTTI interno altamente otimizado e pooling de metadados, resultando em ganhos impressionantes de performance:

*   **Cache RTTI:** Ganho de 40% a 60% na velocidade de lookup.
*   **Busca Otimizada:** Resolução de dependências 15% a 25% mais rápida.
*   **Pool de Memória:** Redução de 20% a 30% no overhead de alocação de objetos Factory.

---

### ⛏️ Contribuição
Adoramos contribuições! Sinta-se à vontade para abrir issues ou enviar pull requests.

### 📬 Contato
*   **Telegram**: [Canal HashLoad](https://t.me/hashload)
*   **Website**: [isaquepinheiro.com.br](https://www.isaquepinheiro.com.br)

### 💲 Doação
[![Doação](https://img.shields.io/badge/PagSeguro-contribua-green)](https://pag.ae/bglQrWD)

---
*Copyright © 2025-2026 Isaque Pinheiro. Licensed under LGPL-3.0 License.*
