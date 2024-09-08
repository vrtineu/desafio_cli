defmodule DesafioCli.CliTest do
  use ExUnit.Case, async: true
  import ExUnit.CaptureIO
  alias DesafioCli.Cli

  setup do
    pid = start_supervised!(DesafioCli.Db, [])
    {:ok, pid: pid}
  end

  describe "loop/0" do
    test "loop handles a single command and exits" do
      input = "SET key value\n"

      output =
        capture_io([input: input, capture_prompt: false], fn ->
          Cli.loop()
          send(self(), :eof)
        end)

      assert output =~ "FALSE value"
    end

    test "loop handles multiple commands and exits" do
      input = "SET key1 value1\nGET key1\n"

      output =
        capture_io([input: input, capture_prompt: false], fn ->
          Cli.loop()
          send(self(), :eof)
        end)

      assert output =~ "FALSE value"
      assert output =~ "value1"
    end

    test "loop handles not supported command" do
      input = "UNKNOWN\n"

      output =
        capture_io([input: input, capture_prompt: false], fn ->
          Cli.loop()
          send(self(), :eof)
        end)

      assert output =~ "ERR \"No command UNKNOWN\""
    end

    test "loop handles no command" do
      input = "\n"

      output =
        capture_io([input: input, capture_prompt: false], fn ->
          Cli.loop()
          send(self(), :eof)
        end)

      assert output =~ "ERR \"No command \""
    end

    test "error if not valid quoted string" do
      input = "SET \"quoted key value\n"

      assert_raise RuntimeError, "Invalid quoted string", fn ->
        capture_io([input: input, capture_prompt: false], fn ->
          Cli.loop()
          send(self(), :eof)
        end)
      end
    end
  end

  describe "parse_command/1" do
    test "parses command without key and value" do
      assert Cli.parse_command("BEGIN") == {"BEGIN", [], []}
    end

    test "parses command with key" do
      assert Cli.parse_command("GET key") == {"GET", ["key"], []}
    end

    test "parses command with key and value" do
      assert Cli.parse_command("SET key value") == {"SET", ["key"], ["value"]}
    end

    test "parses command with key and quoted value" do
      assert Cli.parse_command("SET key \"quoted value\"") == {"SET", ["key"], ["quoted value"]}
    end

    test "parses command with key and quoted key" do
      assert Cli.parse_command("SET \"quoted key\" value") == {"SET", ["quoted key"], ["value"]}
    end

    test "parses command with key and quoted key and value" do
      assert Cli.parse_command("SET \"quoted key\" \"quoted value\"") ==
               {"SET", ["quoted key"], ["quoted value"]}
    end

    test "parses command with key and quoted key and value with spaces" do
      assert Cli.parse_command("SET \"quoted key\" \"quoted value with spaces\"") ==
               {"SET", ["quoted key"], ["quoted value with spaces"]}
    end

    test "parses command with key and quoted key and value with invalid arguments" do
      assert Cli.parse_command("SET \"quoted key\" \"quoted value\" invalid") ==
               {"SET", ["quoted key"], ["quoted value", "invalid"]}
    end
  end
end
