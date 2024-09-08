defmodule DesafioCli.Commands.BeginTest do
  use ExUnit.Case

  alias DesafioCli.Commands.Begin

  setup do
    pid = start_supervised!(DesafioCli.Db, [])
    {:ok, pid: pid}
  end

  describe "execute/0" do
    test "returns new transaction level" do
      {:ok, new_lvl} = Begin.execute()
      assert new_lvl == 1
    end

    test "with recursive calls" do
      {:ok, lvl1} = Begin.execute()
      {:ok, lvl2} = Begin.execute()
      assert lvl1 + 1 == lvl2
    end
  end
end
