defmodule Watchexs.Reload do
  @moduledoc """
  This module contains helpers for reloading and
  recompiling files that have been modified.
  """
  require Logger

  alias IEx.Helpers

  @deps %{
    recompile:    &Helpers.recompile/0,
    compl_opt:    &Code.compiler_options/1,
    load_file:    &Code.load_file/1,
    file_exists:  &File.exists?/1
  }

  def add_new_path(list_path, new_path) do
    if new_path in list_path do
      list_path
    else
      list_path ++ [new_path]
    end
  end

  def tour_list_paths(path_list, deps \\ @deps) do
    path_list
    |> Enum.map(&control_recompile(&1, deps, Path.extname(&1)))
    |> Enum.filter(&(&1 != :ok))
  end

  defp control_recompile(path, deps, ".ex") do
    case reload_or_recompile(path, deps) do
      {:error, msg} ->
        Logger.error "#{inspect msg}"
        path

      _ ->
        Logger.info "Reload or recompile path: #{inspect path}"
        :ok
    end
  end
  defp control_recompile(_path, _deps, ".exs") do
    Logger.info "IS A TEST FILE"
    # ExUnit.Server.modules_loaded()
    # deps.compl_opt.(ignore_module_conflict: true)
    # deps.load_file.(path)
    :ok
  end

  defp reload_or_recompile(path, deps) do
    if deps.file_exists.(path) do
      reload(path, deps)
    else
      recompile(deps)
    end
  end

  defp reload(path, deps) do
    deps.compl_opt.(ignore_module_conflict: true)
    deps.load_file.(path)
  rescue
    ex -> {:error, "Error message #{inspect ex}"}
  end

  defp recompile(deps), do: deps.recompile.()
end
