defmodule DesafioCli.Commands do
  alias DesafioCli.Commands

  def handle({"SET", [key], [value | []]}), do: Commands.Set.execute({key, value})
  def handle({"SET", _, _}), do: {:error, "ERR \"SET <chave> <valor>\""}

  def handle({"GET", [key], []}), do: Commands.Get.execute(key)
  def handle({"GET", _, _}), do: {:error, "ERR \"GET <chave>\""}

  def handle({"BEGIN", [], []}), do: Commands.Begin.execute()
  def handle({"BEGIN", _, _}), do: {:error, "ERR \"Comando não permite parâmetros\""}

  def handle({"ROLLBACK", [], []}), do: Commands.Rollback.execute()
  def handle({"ROLLBACK", _, _}), do: {:error, "ERR \"Comando não permite parâmetros\""}

  def handle({"COMMIT", [], []}), do: Commands.Commit.execute()
  def handle({"COMMIT", _, _}), do: {:error, "ERR \"Comando não permite parâmetros\""}

  def handle({cmd, _, _}), do: {:error, "ERR \"No command #{cmd}\""}
end
