defmodule DesafioCliTest do
  use ExUnit.Case
  import ExUnit.CaptureIO
  doctest DesafioCli

  describe "main/1" do
    test "starts the database and enters the loop" do
      output = capture_io(fn ->
        DesafioCli.main([])
      end)

      assert output =~ "> "
    end
  end
end
