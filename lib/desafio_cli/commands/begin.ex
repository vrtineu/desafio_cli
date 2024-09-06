defmodule DesafioCli.Commands.Begin do
  alias DesafioCli.Db

  def execute(), do: Db.begin()
end
