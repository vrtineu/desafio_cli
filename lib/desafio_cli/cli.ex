defmodule DesafioCli.Cli do
  alias DesafioCli.Commands

  def loop(input_device \\ :stdio, output_device \\ :stdio) do
    receive do
      :eof -> :ok
    after
      0 ->
        case IO.gets(input_device, "> ") do
          :eof ->
            :ok

          input ->
            input
            |> String.trim()
            |> parse_command()
            |> Commands.handle()
            |> response(output_device)

            loop(input_device, output_device)
        end
    end
  end

  def parse_command(input) do
    words = String.split(input)
    parse_command_words(words)
  end

  defp parse_command_words([cmd | rest]) do
    {key, value} = split_key_value(rest)
    {String.upcase(cmd), format_key(key), format_value(value)}
  end

  defp parse_command_words([]), do: {[], [], []}

  defp split_key_value(words) do
    case words do
      [<<"\"", _::binary>> = quoted_start | rest] ->
        {quoted_key, remaining} = extract_quoted_string([quoted_start | rest])
        {quoted_key, remaining}

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
        raise "Invalid quoted string"
    end
  end

  defp format_key(key) when is_bitstring(key) do
    key
    |> String.trim("\"")
    |> List.wrap()
  end

  defp format_key(key) when is_list(key) do
    key
    |> Enum.map(&format_key/1)
  end

  defp format_value(value) when is_list(value) do
    case value do
      [<<"\"", _::binary>> = quoted_start | rest] ->
        {quoted_value, remaining} = extract_quoted_string([quoted_start | rest])
        [String.trim(quoted_value, "\"")] ++ remaining

      _ ->
        value
    end
  end

  defp response({:ok, result}, output_device), do: IO.puts(output_device, result)
  defp response({:error, reason}, output_device), do: IO.puts(output_device, reason)
end
