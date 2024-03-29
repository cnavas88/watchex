defmodule Watchexs.FileWatcher do
  @moduledoc """
  File watcher is a gensever that see the change files in the
  watched_dirs folders.
  """
  require Logger

  alias Mix.Project
  alias Watchexs.Reload

  use GenServer

  @watched_dirs Application.get_env(:watchexs, :watch_dirs)

  # Public API

  @spec start_link() :: Supervisor.on_start()

  def start_link, do: GenServer.start_link(__MODULE__, [])

  # Callbacks

  @impl GenServer

  def init(_) do
    {:ok, watcher_pid} = FileSystem.start_link(dirs: watched_dirs())

    FileSystem.subscribe(watcher_pid)

    state = %{
      watcher_pid: watcher_pid,
      path_with_errors: [],
      deps: %{
        add_new_path: &Reload.add_new_path/2,
        tour_list_paths: &Reload.tour_list_paths/1
      }
    }

    {:ok, state}
  end

  @impl GenServer

  def handle_info(
        {:file_event, watcher_pid, {path, _events}},
        %{watcher_pid: watcher_pid, path_with_errors: error_paths, deps: deps} = state
      ) do
    list_errors =
      error_paths
      |> deps.add_new_path.(path)
      |> deps.tour_list_paths.()

    {:noreply, %{state | path_with_errors: list_errors}}
  end

  @impl GenServer

  def handle_info(
        {:file_event, watcher_pid, :stop},
        %{watcher_pid: watcher_pid} = state
      ) do
    Logger.info("File watcher stopped.")
    {:noreply, state}
  end

  @impl GenServer

  def handle_info(data, state) do
    Logger.info("#{inspect(data)}")
    {:noreply, state}
  end

  # Auxiliary functions

  @spec watched_dirs() :: list()

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
