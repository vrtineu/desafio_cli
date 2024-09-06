defmodule DesafioCli.Commands do
  alias DesafioCli.Commands

  def handle(["SET", key, value]), do: Commands.Set.execute({key, value})
  def handle(["SET" | _]), do: {:error, "ERR \"SET <chave> <valor>\""}

  def handle(["GET", key]), do: Commands.Get.execute(key)
  def handle(["GET" | _]), do: {:error, "ERR \"GET <chave>\""}

  def handle([cmd | _]), do: {:error, "ERR \"No command #{cmd}\""}
end
