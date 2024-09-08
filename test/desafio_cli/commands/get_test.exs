defmodule DesafioCli.Commands.GetTest do
  use ExUnit.Case

  alias DesafioCli.Commands.Get
  alias DesafioCli.Db

  setup do
    pid = start_supervised!(DesafioCli.Db, [])
    {:ok, pid: pid}
  end

  describe "execute/1" do
    test "returns the value for the given key if it exists" do
      Db.set("key", "value")
      assert {:ok, "value"} = Get.execute("key")
    end

    test "returns NIL if the key does not exist" do
      assert {:ok, "NIL"} = Get.execute("key")
    end
  end
end
