defmodule Watchexs do
  @moduledoc false

  use Application
  import Supervisor.Spec, warn: true

  def start(_type, _args) do
    enabled = Application.get_env(:watchexs, :enabled)

    opts = [strategy: :one_for_one, name: Watchexs.Supervisor]
    Supervisor.start_link(get_childrens(enabled), opts)
  end

  @spec get_childrens(boolean()) :: list()

  defp get_childrens(true) do
    [
      worker(Watchexs.FileWatcher, []),
      worker(Watchexs.GenserverTest, [])
    ]
  end

  defp get_childrens(false), do: []
end
