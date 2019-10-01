defmodule Watchexs.FileWatcher do
  @moduledoc """
  File watcher is a gensever that see the change files in the
  watched_dirs folders.
  """
  alias Mix.Project
  alias Watchexs.Reload

  use GenServer

  @watched_dirs Application.get_env(:watchexs, :watch_dirs)

  # Public API

  def start_link, do: GenServer.start_link(__MODULE__, [])

  # Callbacks

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
      %{watcher_pid: watcher_pid,
        path_with_errors: error_paths} = state) do
    list_errors =
      error_paths
      |> Reload.add_new_path(path)
      |> Reload.tour_list_paths()

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

  # Auxiliary functions

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
end
