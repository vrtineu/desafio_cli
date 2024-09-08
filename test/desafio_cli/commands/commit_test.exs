defmodule DesafioCli.Commands.CommitTest do
  use ExUnit.Case

  alias DesafioCli.Commands.Commit
  alias DesafioCli.Db

  setup do
    pid = start_supervised!(DesafioCli.Db, [])
    {:ok, pid: pid}
  end

  describe "execute/0" do
    test "returns :ok if there's any transaction started before" do
      Db.begin()
      {:ok, _} = Commit.execute()
    end

    test "returns error if there's no transaction started before" do
      assert {:error, "ERR \"Transação não iniciada\""} = Commit.execute()
    end
  end
end
