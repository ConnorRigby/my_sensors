defmodule MySensors.PacketTest do
  @moduledoc "Tests packet parsing"
  alias MySensors.Packet
  use Packet.Constants
  use ExUnit.Case, async: true
  doctest Packet

  test "parses presentation command" do
    assert Packet.command(0) == {:ok, @command_PRESENTATION}
    assert Packet.command(0) == {:ok, :command_presentation}
    assert Packet.command(@command_PRESENTATION) == {:ok, 0}
    assert Packet.command(:command_presentation) == {:ok, 0}
  end

  test "parses set command" do
    assert Packet.command(1) == {:ok, @command_SET}
    assert Packet.command(1) == {:ok, :command_set}
    assert Packet.command(@command_SET) == {:ok, 1}
    assert Packet.command(:command_set) == {:ok, 1}
  end

  test "parses req command" do
    assert Packet.command(2) == {:ok, @command_REQ}
    assert Packet.command(2) == {:ok, :command_req}
    assert Packet.command(@command_REQ) == {:ok, 2}
    assert Packet.command(:command_req) == {:ok, 2}
  end

  test "parses internal command" do
    assert Packet.command(3) == {:ok, @command_INTERNAL}
    assert Packet.command(3) == {:ok, :command_internal}
    assert Packet.command(@command_INTERNAL) == {:ok, 3}
    assert Packet.command(:command_internal) == {:ok, 3}
  end

  test "parses stream command" do
    assert Packet.command(4) == {:ok, @command_STREAM}
    assert Packet.command(4) == {:ok, :command_stream}
    assert Packet.command(@command_STREAM) == {:ok, 4}
    assert Packet.command(:command_stream) == {:ok, 4}
  end
end
