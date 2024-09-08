defmodule DesafioCli.Commands.RollbackTest do
  use ExUnit.Case

  alias DesafioCli.Commands.Rollback
  alias DesafioCli.Db

  setup do
    pid = start_supervised!(DesafioCli.Db, [])
    {:ok, pid: pid}
  end

  describe "execute/0" do
    test "returns the new level if there's any transaction started before" do
      Db.begin()
      {:ok, _} = Rollback.execute()
    end

    test "returns error if there's no transaction started before" do
      assert {:error, "ERR \"Transação não iniciada\""} = Rollback.execute()
    end
  end
end
