defmodule Watchexs.Reload do
  @moduledoc """
  This module contains helpers for reloading and
  recompiling files that have been modified.
  """
  require Logger

  alias IEx.Helpers

  @deps %{
    recompile: &Helpers.recompile/0,
    compl_opt: &Code.compiler_options/1,
    load_file: &Code.load_file/1,
    file_exists: &File.exists?/1,
    test_start: &ExUnit.start/0
  }

  @test_extension ".exs"

  @spec add_new_path(list(), String.t()) :: list()

  def add_new_path(list_path, new_path) do
    if new_path in list_path do
      list_path
    else
      list_path ++ [new_path]
    end
  end

  @spec tour_list_paths(list(), map()) :: list()

  def tour_list_paths(path_list, deps \\ @deps) do
    path_list
    |> Enum.map(&control_recompile(&1, deps))
    |> Enum.filter(&(&1 != :ok))
  end

  @spec control_recompile(String.t(), map()) :: String.t() | :ok

  defp control_recompile(path, deps) do
    if Path.extname(path) == @test_extension, do: deps.test_start.()

    case reload_or_recompile(path, deps) do
      {:error, msg} ->
        Logger.error("#{inspect(msg)}")
        path

      _ ->
        Logger.info("Reload or recompile path: #{inspect(path)}")
        :ok
    end
  end

  @spec reload_or_recompile(String.t(), map()) :: list() | tuple()

  defp reload_or_recompile(path, deps) do
    if deps.file_exists.(path) do
      reload(path, deps)
    else
      recompile(deps)
    end
  end

  @spec reload(String.t(), map()) :: list() | tuple()

  defp reload(path, deps) do
    deps.compl_opt.(ignore_module_conflict: true)
    deps.load_file.(path)
  rescue
    ex -> {:error, "Error message #{inspect(ex)}"}
  end

  @spec recompile(map()) :: list()

  defp recompile(deps), do: deps.recompile.()
end
