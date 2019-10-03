defmodule Watchexs.ReloadTest do
  use ExUnit.Case
  doctest Watchexs

  alias Watchexs.Reload

  describe "adding_new_path/2" do
    test "new path to list" do
      list = ["/test", "/path"]
      path = "/reload"
      result = Reload.add_new_path(list, path)
      expected_result = ["/test", "/path", "/reload"]
      assert result == expected_result
    end

    test "existing path to list" do
      list = ["/test", "/path", "/reload"]
      path = "/reload"
      result = Reload.add_new_path(list, path)
      expected_result = ["/test", "/path", "/reload"]
      assert result == expected_result
    end
  end

  describe "tour_list_paths/2" do
    test "reload file ok" do
      path_list = ["reload.ex"]
            
      deps = %{
        compl_opt: fn _ -> :ok end,
        load_file: fn _ -> [] end,
        file_exists: fn _ -> true end
      }

      result = Reload.tour_list_paths(path_list, deps)
      expected_result = []

      assert result == expected_result
    end
    
    test "recompile file ok" do
      path_list = ["reload.ex"]
            
      deps = %{
        recompile: fn -> :ok end,
        file_exists: fn _ -> false end
      }

      result = Reload.tour_list_paths(path_list, deps)
      expected_result = []

      assert result == expected_result
    end

    test "reload file with raise error" do
      path_list = ["reload.ex"]
            
      deps = %{
        compl_opt: fn _ -> :ok end,
        load_file: fn _ -> 
          raise "keep calm and raise error."
        end,
        file_exists: fn _ -> true end
      }

      result = Reload.tour_list_paths(path_list, deps)
      expected_result = ["reload.ex"]

      assert result == expected_result
    end
  end
end
