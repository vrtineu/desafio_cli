defmodule DesafioCli.Commands.Commit do

  alias DesafioCli.Db

  def execute() do
    with {:ok, new_lvl} <- Db.commit() do
      {:ok, new_lvl}
    else
      {:error, :not_allowed} ->
        {:error, "ERR \"Transação não iniciada\""}
    end
  end
end
