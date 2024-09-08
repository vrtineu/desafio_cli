defmodule DesafioCli.CommandsTest do
  use ExUnit.Case

  alias DesafioCli.Commands

  setup do
    pid = start_supervised!(DesafioCli.Db, [])
    {:ok, pid: pid}
  end

  describe "handle/1" do
    test "SET command with key and value" do
      result1 = Commands.handle({"SET", ["key"], ["value"]})
      result2 = Commands.Set.execute({"key", "value"})
      assert elem(result1, 0) == elem(result2, 0)
    end

    test "SET command without key and value" do
      assert Commands.handle({"SET", [], []}) == {:error, "ERR \"SET <chave> <valor>\""}
    end

    test "GET command with key" do
      assert Commands.handle({"GET", ["key"], []}) == Commands.Get.execute("key")
    end

    test "GET command without key" do
      assert Commands.handle({"GET", [], []}) == {:error, "ERR \"GET <chave>\""}
    end

    test "BEGIN command without parameters" do
      result1 = Commands.handle({"BEGIN", [], []})
      result2 = Commands.Begin.execute()
      assert elem(result1, 0) == elem(result2, 0)
    end

    test "BEGIN command with parameters" do
      assert Commands.handle({"BEGIN", ["param"], ["param"]}) ==
               {:error, "ERR \"Comando não permite parâmetros\""}
    end

    test "ROLLBACK command without parameters" do
      assert Commands.handle({"ROLLBACK", [], []}) == Commands.Rollback.execute()
    end

    test "ROLLBACK command with parameters" do
      assert Commands.handle({"ROLLBACK", ["param"], ["param"]}) ==
               {:error, "ERR \"Comando não permite parâmetros\""}
    end

    test "COMMIT command without parameters" do
      assert Commands.handle({"COMMIT", [], []}) == Commands.Commit.execute()
    end

    test "COMMIT command with parameters" do
      assert Commands.handle({"COMMIT", ["param"], ["param"]}) ==
               {:error, "ERR \"Comando não permite parâmetros\""}
    end

    test "Unknown command" do
      assert Commands.handle({"UNKNOWN", [], []}) == {:error, "ERR \"No command UNKNOWN\""}
    end
  end
end
