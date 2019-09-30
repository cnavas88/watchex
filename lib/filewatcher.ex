defmodule Watchexs.FileWatcher do
  @moduledoc """
  File watcher is a gensever that see the change files in the
  watched_dirs folders.
  """
  require Logger

  alias IEx.Helpers
  alias Mix.Project

  use GenServer

  @watched_dirs Application.get_env(:watchexs, :watch_dirs)

  def start_link, do: GenServer.start_link(__MODULE__, [])

  def init(_) do
    {:ok, watcher_pid} =
      FileSystem.start_link(dirs: watched_dirs())

    FileSystem.subscribe(watcher_pid)

    state = %{
      watcher_pid: watcher_pid,
      path_with_errors: []
    }

    {:ok, state}
  end

  def handle_info({:file_event, watcher_pid, {path, _events}},
      %{watcher_pid: watcher_pid} = state) do
    list_errors =
      tour_list_paths(state.path_with_errors ++ [path])

    {:noreply, %{state | path_with_errors: list_errors}}
  end

  def handle_info({:file_event, watcher_pid, :stop},
      %{watcher_pid: watcher_pid} = state) do
    IO.puts "File watcher stopped."
    {:noreply, state}
  end

  def handle_info(data, state) do
    IO.puts "#{inspect data}"
    {:noreply, state}
  end

  defp tour_list_paths(path_list) do
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
        Logger.info "Reload project."
        :ok
    end
  end

  defp watched_dirs do
    Project.deps_paths()
    |> Stream.flat_map(fn {_dep_name, dir} ->
      @watched_dirs
      |> Enum.map(fn watched_dir ->
        Path.join(dir, watched_dir)
      end)
    end)
    |> Stream.concat(@watched_dirs)
    |> Enum.filter(&File.dir?/1)
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
