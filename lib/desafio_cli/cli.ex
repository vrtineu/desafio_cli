defmodule DesafioCli.Cli do
  alias DesafioCli.Commands

  def loop() do
    "> "
    |> IO.gets()
    |> parse_command()
    |> Commands.handle()
    |> response()

    loop()
  end

  defp parse_command(input) do
    [cmd | rest] =
      input
      |> String.trim()
      |> String.split(" ", trim: true)

    [String.upcase(cmd) | rest]
  end

  defp response({:ok, result}), do: IO.write("#{result}\n")
  defp response({:error, reason}), do: IO.write("#{reason}\n")
end
