defmodule DesafioCli.Commands.SetTest do
  use ExUnit.Case

  alias DesafioCli.Commands.Set
  alias DesafioCli.Db

  setup do
    pid = start_supervised!(DesafioCli.Db, [])
    {:ok, pid: pid}
  end

  describe "execute/1" do
    test "returns FALSE and new value if the key not already exists" do
      assert {:ok, "FALSE value"} = Set.execute({"key", "value"})
    end

    test "returns TRUE and new value if the key already exists" do
      Db.set("key", "value")
      assert {:ok, "TRUE value2"} = Set.execute({"key", "value2"})
    end

    test "returns error if the value is invalid" do
      assert {:error, "ERR \"Valor inválido\""} = Set.execute({"key", "NIL"})
    end

    test "sets a boolean value" do
      assert {:ok, "FALSE true"} = Set.execute({"key", "true"})
      assert {:ok, "TRUE false"} = Set.execute({"key", "false"})
    end

    test "sets a number value" do
      assert {:ok, "FALSE 1"} = Set.execute({"key", "1"})
      assert {:ok, "TRUE 0"} = Set.execute({"key", "0"})
    end
  end
end
