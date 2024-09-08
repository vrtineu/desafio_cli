defmodule DesafioCli.Commands.Set do
  @moduledoc """
  Módulo responsável por implementar o comando SET.
  """

  alias DesafioCli.Db

  @not_allowed_values ~w(NIL)

  def execute({key, value}) do
    with typed_value <- convert!(value),
         true <- is_valid_value?(typed_value) do
      case Db.get(key) do
        nil ->
          Db.set(key, value)

          {:ok, "FALSE #{value}"}

        _old_value ->
          Db.set(key, value)

          {:ok, "TRUE #{value}"}
      end
    else
      false -> {:error, "ERR \"Valor inválido\""}
      _ -> {:error, "ERR \"Erro interno\""}
    end
  end

  defp convert!("true"), do: true
  defp convert!("false"), do: false

  defp convert!(value) do
    case Integer.parse(value) do
      {number, _} -> number
      _ -> value
    end
  end

  defp is_valid_value?(value) when is_bitstring(value) do
    not Enum.member?(@not_allowed_values, String.upcase(value))
  end

  defp is_valid_value?(value) when is_boolean(value), do: true
  defp is_valid_value?(value) when is_number(value), do: true
end
