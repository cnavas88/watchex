defmodule Watchexs.FileWatcher do
  @moduledoc """
  File watcher is a gensever that see the change files in the
  watched_dirs folders.
  """
  require Logger

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
      %{watcher_pid: watcher_pid,
        path_with_errors: list_errors} = state) do
    IO.puts "LIST ERRORS :: #{inspect list_errors}"
    case reload_or_recompile(path) do
      {:error, msg} ->
        IO.puts "ERROR :: #{inspect msg}"
        {:noreply, get_new_state(state, path)}

      _ ->
        Logger.info "Reload project."
        {:noreply, state}
    end
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

  defp get_new_state(%{path_with_errors: errors_list} = state, path) do
    if path in errors_list do
      state
    else
      %{state | path_with_errors: errors_list ++ [path]}
    end
  end

  defp watched_dirs do
    Mix.Project.deps_paths()
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

  defp recompile, do: IEx.Helpers.recompile()
end

# %CompileError{description: "undefined function path/0", file: "/Users/carlosnavas/watchex/lib/prueba.ex", line: 3}
# EXCEPTION :: %Code.LoadError{file: "/Users/carlosnavas/watchex/asgdasgd/asdasdasdasd.exå", message: "could not load /Users/carlosnavas/watchex/asgdasgd/asdasdasdasd.exå"}


# crear un estado con una lista de archivos que no se han
# podido ni recompilar ni cargar, para probarlo antes
