defmodule DesafioCli.Db do
  @moduledoc """
  Este módulo implementa um banco de dados key-value simples in-memory com suporte a transações.

  Existe suporte a operações de `get` e `set`, bem como transações com `begin`, `rollback` e `commit`.
  """

  use GenServer

  alias __MODULE__

  @type key :: String.t()
  @type value :: String.t() | integer() | boolean()

  defmodule State do
    @moduledoc false

    @type t :: %__MODULE__{
            data: %{Db.key() => Db.value()},
            stack: list(map()),
            level: non_neg_integer()
          }

    defstruct data: %{}, stack: [], level: 0
  end

  @doc """
  Inicia o DB GenServer com um estado vazio.

  ## Exemplos

      iex> DesafioCli.Db.start_link([])
      {:ok, #PID<0.123.0>}
  """
  @spec start_link([any()]) :: {:ok, pid()}
  def start_link(_) do
    GenServer.start_link(Db, %{}, name: Db)
  end

  @impl true
  def init(_) do
    {:ok, %State{}}
  end

  ##############
  # Public API #
  ##############

  @doc """
  Recupera o valor associado a uma chave.

  ## Exemplos

      iex> DesafioCli.Db.get("foo")
      nil

      iex> DesafioCli.Db.set("foo", "bar")
      :ok

      iex> DesafioCli.Db.get("foo")
      "bar"
  """
  @spec get(key()) :: value() | nil
  def get(key) do
    GenServer.call(Db, {:get, key})
  end

  @doc """
  Define o valor associado a uma chave.

  ## Exemplos

      iex> DesafioCli.Db.set("foo", "bar")
      :ok

      iex> DesafioCli.Db.get("foo")
      "bar"
  """
  @spec set(key(), value()) :: :ok
  def set(key, value) do
    GenServer.call(Db, {:set, key, value})
  end

  @doc """
  Inicia uma nova transação.

  Retorna o nível da transação iniciada.

  ## Exemplos

      iex> DesafioCli.Db.begin()
      {:ok, 1}
  """
  @spec begin() :: {:ok, non_neg_integer()}
  def begin() do
    GenServer.call(Db, {:begin})
  end

  @doc """
  Desfaz a última transação.

  Retorna o nível da transação após o rollback ou um erro caso não exista transação em andamento.

  ## Exemplos

      iex> DesafioCli.Db.begin()
      {:ok, 1}

      iex> DesafioCli.Db.rollback()
      {:ok, 0}

      iex> DesafioCli.Db.rollback()
      {:error, :not_allowed}
  """
  @spec rollback() :: {:ok, non_neg_integer()} | {:error, :not_allowed}
  def rollback() do
    GenServer.call(Db, {:rollback})
  end

  @doc """
  Confirma a transação atual.

  Retorna o nível da transação após o commit ou um erro caso não exista transação em andamento.

  ## Exemplos

      iex> DesafioCli.Db.begin()
      {:ok, 1}

      iex> DesafioCli.Db.commit()
      {:ok, 0}

      iex> DesafioCli.Db.commit()
      {:error, :not_allowed}
  """
  @spec commit() :: {:ok, non_neg_integer()} | {:error, :not_allowed}
  def commit() do
    GenServer.call(Db, {:commit})
  end

  ###############
  # Private API #
  ###############

  @impl true
  def handle_call({:get, key}, _from, %State{data: data} = state) do
    {:reply, Map.get(data, key), state}
  end

  @impl true
  def handle_call({:set, key, value}, _from, %State{data: data} = state) do
    {:reply, :ok, %{state | data: Map.put(data, key, value)}}
  end

  @impl true
  def handle_call({:begin}, _from, %State{data: data, stack: stack, level: level} = state) do
    new_lvl = increase_lvl(level)

    {:reply, {:ok, new_lvl}, %State{state | stack: [data | stack], level: new_lvl}}
  end

  @impl true
  def handle_call({:rollback}, _from, %State{stack: stack, level: level} = state) do
    with {:ok, new_lvl} <- decrease_lvl(level) do
      [previous_snapshot | rest] = stack

      {:reply, {:ok, new_lvl}, %State{data: previous_snapshot, stack: rest, level: new_lvl}}
    else
      error -> {:reply, error, state}
    end
  end

  @impl true
  def handle_call({:commit}, _from, %State{stack: stack, level: level} = state) do
    with {:ok, new_lvl} <- decrease_lvl(level) do
      [_ | rest] = stack

      {:reply, {:ok, new_lvl}, %State{state | stack: rest, level: new_lvl}}
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
