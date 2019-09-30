defmodule Watchexs.Reload do
  @moduledoc """
  This module contains helpers for reloading and
  recompiling files that have been modified.
  """
  require Logger

  alias IEx.Helpers

  def add_new_path(list_path, new_path) do
    if new_path in list_path do
      list_path
    else
      list_path ++ [new_path]
    end
  end

  def tour_list_paths(path_list) do
    path_list
    |> Enum.map(&control_recompile(&1))
    |> Enum.filter(&(&1 != :ok))
  end

  defp control_recompile(path) do
    case reload_or_recompile(path) do
      {:error, msg} ->
        Logger.error "#{inspect msg}"
        path

      _ ->
        Logger.info "Reload or recompile path: #{inspect path}"
        :ok
    end
  end

  defp reload_or_recompile(path) do
    if File.exists?(path) do
      reload(path)
    else
      recompile()
    end
  end

  defp reload(path) do
    Code.compiler_options(ignore_module_conflict: true)
    Code.load_file(path)
  rescue
    ex -> {:error, "Error message #{inspect ex}"}
  end

  defp recompile, do: Helpers.recompile()
end
