defmodule MySensors.Transport do
  @moduledoc """
  Behaviour for MySensors transports to implement.
  """
  alias MySensors.Packet

  @doc "Write a packet."
  @callback write(GenServer.server(), Packet.t()) :: :ok | {:error, term}

  @doc "Validate opts passed to the transport."
  @callback opts(Keyword.t()) :: {:ok, Keyword.t()} | {:error, term}
end
