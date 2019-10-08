defmodule Watchexs do
  @moduledoc """
  Application module for start the watchexs extension. This module contains
  the switch for enabled or disabled the watchexs functions. And supervisor
  the genserver filewatcher with a one for one strategy.
  According the enabled config variable, the childs are [] or [FileWatcher]
  """
  use Application
  import Supervisor.Spec, warn: true

  @spec start(any, list()) :: {:error, any} | {:ok, pid()} | {:ok, pid(), any}

  def start(_type, _args) do
    enabled = Application.get_env(:watchexs, :enabled)

    opts = [strategy: :one_for_one, name: Watchexs.Supervisor]
    Supervisor.start_link(get_childrens(enabled), opts)
  end

  @spec get_childrens(boolean()) :: list()

  defp get_childrens(true) do
    [
      worker(Watchexs.FileWatcher, [])
    ]
  end

  defp get_childrens(false), do: []
end
