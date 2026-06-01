{
  ------------------------------------------------------------------------------
  InjectContainer
  High-performance, thread-safe Dependency Injection (DI) framework for Delphi.

  SPDX-License-Identifier: MIT
  Copyright (c) 2025-2026 Isaque Pinheiro

  Licensed under the MIT License.
  See the LICENSE file in the project root for full license information.
  ------------------------------------------------------------------------------
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
