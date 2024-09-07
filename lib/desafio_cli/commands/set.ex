defmodule DesafioCli.Commands.Set do
  @moduledoc """
  Módulo responsável por implementar o comando SET.
  """

  alias DesafioCli.Db

  @not_allowed_values ~w(NIL)

  def execute({key, value}) do
    with true <- is_valid_value?(value) do
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
    end
  end

  defp is_valid_value?(value) when is_bitstring(value) do
    not Enum.member?(@not_allowed_values, String.upcase(value))
  end

  defp is_valid_value?(value) when is_boolean(value), do: true
  defp is_valid_value?(value) when is_number(value), do: true
  defp is_valid_value?(_), do: false
end
