defmodule DesafioCli.Commands.Set do
  @moduledoc """
  Módulo responsável por implementar o comando SET.
  """

  alias DesafioCli.Db

  def execute({key, value}) do
    case Db.get(key) do
      nil ->
        Db.set(key, value)

        {:ok, "FALSE #{value}"}

      _ ->
        Db.set(key, value)

        {:ok, "TRUE #{value}"}
    end
  end
end
