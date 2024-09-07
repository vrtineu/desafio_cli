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

  def parse_command(input) do
    words = String.split(input)
    parse_command_words(words)
  end

  defp parse_command_words([cmd | rest]) do
    {key, value} = split_key_value(rest)

    {String.upcase(cmd), format_key(key), value}
  end

  defp split_key_value(words) do
    case words do
      [<<"\"", _::binary>> = quoted_start | rest] ->
        {quoted_key, remaining} = extract_quoted_string([quoted_start | rest])
        {quoted_key, remaining}

      [single_word] ->
        {single_word, []}

      [key | value] ->
        {key, value}

      [] ->
        {[], []}
    end
  end

  defp extract_quoted_string(words, acc \\ []) do
    case words do
      [word | rest] ->
        if String.ends_with?(word, "\"") do
          {Enum.reverse([word | acc]) |> Enum.join(" "), rest}
        else
          extract_quoted_string(rest, [word | acc])
        end

      [] ->
        {Enum.reverse(acc) |> Enum.join(" "), []}
    end
  end

  defp format_key([]), do: []

  defp format_key(key) do
    key
    |> String.trim("\"")
    |> List.wrap()
  end

  defp response({:ok, result}), do: IO.write("#{result}\n")
  defp response({:error, reason}), do: IO.write("#{reason}\n")
end
