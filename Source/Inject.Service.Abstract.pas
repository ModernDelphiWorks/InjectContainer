{
  ------------------------------------------------------------------------------
  InjectContainer
  Lightweight dependency injection container for Delphi applications.

  SPDX-License-Identifier: Apache-2.0
  Copyright (c) 2025-2026 Isaque Pinheiro

  Licensed under the Apache License, Version 2.0.
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
