defmodule DesafioCli.DbTest do
  use ExUnit.Case, async: true

  alias DesafioCli.Db
  alias DesafioCli.Db.State

  setup do
    pid = start_supervised!(Db, [])
    {:ok, pid: pid}
  end

  describe "when starting db" do
    test("start_link/1 starts a GenServer", %{pid: pid}, do: assert(is_pid(pid)))

    test "init/1 returns an empty Db.State" do
      {:ok, %State{} = state} = Db.init([])
      assert state == %State{data: %{}, stack: [], level: 0}
    end
  end

  describe "when getting values" do
    test "get/1 returns the value for a key" do
      Db.set(:foo, "bar")
      assert Db.get(:foo) == "bar"
    end

    test "get/1 returns nil for a missing key" do
      assert Db.get(:missing) == nil
    end

    test "handle_call/3 returns the value for a key" do
      state = %State{data: %{foo: "bar"}}
      assert {:reply, "bar", %State{}} = Db.handle_call({:get, :foo}, nil, state)
    end

    test "handle_call/3 returns nil for a missing key" do
      state = %State{data: %{}}
      assert {:reply, nil, %State{}} = Db.handle_call({:get, :missing}, nil, state)
    end
  end

  describe "when setting values" do
    test "set/2 returns :ok" do
      assert :ok = Db.set("foo", "bar")
    end

    test "handle_call/3 returns :ok and a state with new value" do
      expected_return = {:reply, :ok, %State{data: %{"foo" => "bar"}}}
      assert expected_return == Db.handle_call({:set, "foo", "bar"}, nil, %State{})
    end
  end

  describe "when starting a new transaction" do
    test "begin/0 returns new transaction level" do
      {:ok, new_lvl} = Db.begin()
      assert new_lvl == 1
    end

    test "begin/0 with recursive calls" do
      {:ok, lvl1} = Db.begin()
      {:ok, lvl2} = Db.begin()
      {:ok, lvl3} = Db.begin()

      assert lvl1 == 1
      assert lvl2 == 2
      assert lvl3 == 3
    end

    test "handle_call/3 stores a current state snapshot and increase transaction level" do
      expected_return = {:reply, {:ok, 1}, %State{level: 1, stack: [%{}]}}
      assert expected_return == Db.handle_call({:begin}, nil, %State{})
    end

    test "handle_call/3 with recursive calls" do
      expected_return = {:reply, {:ok, 1}, %State{level: 1, stack: [%{}]}}
      {_, _, state} = result = Db.handle_call({:begin}, nil, %State{})
      assert expected_return == result

      expected_return = {:reply, {:ok, 2}, %State{level: 2, stack: [%{}, %{}]}}
      {_, _, state} = result = Db.handle_call({:begin}, nil, state)
      assert expected_return == result

      expected_return = {:reply, {:ok, 3}, %State{level: 3, stack: [%{}, %{}, %{}]}}
      assert expected_return == Db.handle_call({:begin}, nil, state)
    end
  end

  describe "when rolling back a transaction" do
    test "rollback/0 returns new transaction level" do
      Db.begin()
      {:ok, new_lvl} = Db.rollback()
      assert new_lvl == 0
    end

    test "rollback/0 with recursive calls" do
      Db.begin()
      Db.begin()
      {:ok, lvl1} = Db.rollback()
      {:ok, lvl2} = Db.rollback()

      assert lvl1 == 1
      assert lvl2 == 0
    end

    test "rollback/0 returns error if there is no transaction" do
      assert {:error, :not_allowed} = Db.rollback()
    end

    test "handle_call/3 restores previous state snapshot and decrease transaction level" do
      state = %State{stack: [%{"foo" => "bar"}], level: 1}
      expected_return = {:reply, {:ok, 0}, %State{data: %{"foo" => "bar"}, stack: [], level: 0}}
      assert expected_return == Db.handle_call({:rollback}, nil, state)
    end

    test "handle_call/3 with recursive calls" do
      state = %State{stack: [%{"bar" => "baz", "foo" => "bar"}, %{}], level: 2}
      {_, _, state} = result = Db.handle_call({:rollback}, nil, state)
      expected_return = {:reply, {:ok, 1}, %State{data: %{"bar" => "baz", "foo" => "bar"}, stack: [%{}], level: 1}}
      assert expected_return == result

      expected_return = {:reply, {:ok, 0}, %State{data: %{}, stack: [], level: 0}}
      assert expected_return == Db.handle_call({:rollback}, nil, state)
    end
  end

  describe "when committing a transaction" do
    test "commit/0 returns new transaction level" do
      Db.begin()
      {:ok, new_lvl} = Db.commit()
      assert new_lvl == 0
    end

    test "commit/0 with recursive calls" do
      Db.begin()
      Db.begin()
      {:ok, lvl1} = Db.commit()
      {:ok, lvl2} = Db.commit()

      assert lvl1 == 1
      assert lvl2 == 0
    end

    test "commit/0 returns error if there is no transaction" do
      assert {:error, :not_allowed} = Db.commit()
    end

    test "handle_call/3 removes current state snapshot and decrease transaction level" do
      state = %State{data: %{"foo" => "baz"}, stack: [%{"foo" => "bar"}], level: 1}
      expected_return = {:reply, {:ok, 0}, %State{data: %{"foo" => "baz"}, stack: [], level: 0}}
      assert expected_return == Db.handle_call({:commit}, nil, state)
    end

    test "handle_call/3 with recursive calls" do
      state = %State{data: %{"bar" => "baz", "foo" => "baz"}, stack: [%{"bar" => "baz", "foo" => "bar"}, %{}], level: 2}
      {_, _, state} = result = Db.handle_call({:commit}, nil, state)
      expected_return = {:reply, {:ok, 1}, %State{data: %{"bar" => "baz", "foo" => "baz"}, stack: [%{}], level: 1}}
      assert expected_return == result

      expected_return = {:reply, {:ok, 0}, %State{data: %{"bar" => "baz", "foo" => "baz"}, stack: [], level: 0}}
      assert expected_return == Db.handle_call({:commit}, nil, state)
    end
  end
end
