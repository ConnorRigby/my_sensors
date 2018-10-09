defmodule MySensors.Transport do
  @moduledoc """
  Behaviour for MySensors transports to implement.
  """
  alias MySensors.Packet

  def child_spec([module, opts]) do
    %{
      id: module,
      start: {MySensors.Gateway, :add_transport, [module, opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  @doc "Write a packet."
  @callback write(GenServer.server(), Packet.t()) :: :ok | {:error, term}

  @doc "Validate opts passed to the transport."
  @callback opts(Keyword.t()) :: {:ok, Keyword.t()} | {:error, term}
end
