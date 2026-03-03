{
  ------------------------------------------------------------------------------
  InjectContainer
  Lightweight and modular Dependency Injection container for Delphi.
  Copyright (c) 2023-2026 Isaque Pinheiro

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
  ------------------------------------------------------------------------------
}

{
  @abstract(InjectContainer - Modular Dependency Injection for Delphi)

  @description(
    InjectContainer provides a lightweight, extensible, and modular
    dependency injection container for Delphi applications.
    It supports constructor injection, service registration,
    lifetime management, and clean architecture patterns.
  )

  @author(Isaque Pinheiro)
  @created(2023-04-03)
}

unit Inject.Service.Abstract;

interface

uses
  Inject;

type
  TServiceDataAbstract = class
  protected
    FOwner: TInject;
  end;

implementation

end.
