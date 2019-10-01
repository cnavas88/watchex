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
end
