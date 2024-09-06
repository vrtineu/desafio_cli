defmodule DesafioCli.Commands.Get do
  alias DesafioCli.Db

  def execute(key) do
    case Db.get(key) do
      nil ->
        {:ok, "NIL"}

      value ->
        {:ok, value}
    end
  end
end
