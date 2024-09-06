defmodule DesafioCli.Db do
  @moduledoc """
  This module is responsible for storing key-value pairs.
  """

  use GenServer

  alias __MODULE__

  defstruct data: %{}

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

  ###############
  # Private API #
  ###############

  @impl true
  def handle_call({:get, key}, _from, state) do
    {:reply, Map.get(state.data, key), state}
  end

  @impl true
  def handle_call({:set, key, value}, _from, state) do
    {:reply, :ok, %{state | data: Map.put(state.data, key, value)}}
  end
end
