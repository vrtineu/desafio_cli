defmodule DesafioCli.Db do
  @moduledoc """
  This module is responsible for storing key-value pairs.
  """

  use GenServer

  alias __MODULE__

  defstruct data: %{}, stack: [], level: 0

  def start_link(_) do
    GenServer.start_link(Db, %{}, name: Db)
  end

  @impl true
  def init(_) do
    {:ok, %Db{}}
  end

  ##############
  # Public API #
  ##############

  def get(key) do
    GenServer.call(Db, {:get, key})
  end

  def set(key, value) do
    GenServer.call(Db, {:set, key, value})
  end

  def begin() do
    GenServer.call(Db, {:begin})
  end

  def rollback() do
    GenServer.call(Db, {:rollback})
  end

  def commit() do
    GenServer.call(Db, {:commit})
  end

  ###############
  # Private API #
  ###############

  @impl true
  def handle_call({:get, key}, _from, %Db{data: data} = state) do
    {:reply, Map.get(data, key), state}
  end

  @impl true
  def handle_call({:set, key, value}, _from, %Db{data: data} = state) do
    {:reply, :ok, %{state | data: Map.put(data, key, value)}}
  end

  @impl true
  def handle_call({:begin}, _from, %Db{data: data, stack: stack, level: level} = state) do
    new_lvl = increase_lvl(level)

    {:reply, {:ok, new_lvl}, %Db{state | stack: [data | stack], level: new_lvl}}
  end

  @impl true
  def handle_call({:rollback}, _from, %Db{stack: stack, level: level} = state) do
    with {:ok, new_lvl} <- decrease_lvl(level) do
      [previous_snapshot | rest] = stack

      {:reply, {:ok, new_lvl}, %Db{data: previous_snapshot, stack: rest, level: new_lvl}}
    else
      error -> {:reply, error, state}
    end
  end

  @impl true
  def handle_call({:commit}, _from, %Db{stack: stack, level: level} = state) do
    with {:ok, new_lvl} <- decrease_lvl(level) do
      [_ | rest] = stack

      {:reply, {:ok, new_lvl}, %Db{state | stack: rest, level: new_lvl}}
    else
      error -> {:reply, error, state}
    end
  end

  defp increase_lvl(curr_lvl), do: curr_lvl + 1

  defp decrease_lvl(curr_lvl) do
    new_lvl = curr_lvl - 1

    cond do
      new_lvl >= 0 ->
        {:ok, new_lvl}

      true ->
        {:error, :not_allowed}
    end
  end
end
