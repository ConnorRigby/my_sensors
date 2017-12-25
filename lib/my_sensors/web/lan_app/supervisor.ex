defmodule MySensors.Web.LanApp.Supervisor do
  @moduledoc "Local Area Network WebApp."

  alias MySensors.Web.LanApp.{Router, ResourceSocket}
  @port Application.get_env(:my_sensors, :lan_app)[:port]
  @port || raise "Configure your lan app port"

  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], [name: __MODULE__])
  end

  def init([]) do
    plug_opts = [port: @port, acceptors: 2, dispatch: [cowboy_dispatch()]]
    children = [
      Plug.Adapters.Cowboy.child_spec(:http, Router, [], plug_opts)
    ]
    opts = [
      strategy: :one_for_one
    ]
    supervise(children, opts)
  end

  defp cowboy_dispatch do
    {:_,
      [
        {"/resource_socket", ResourceSocket, []},
        {:_, Plug.Adapters.Cowboy.Handler, {Router, []}},
      ]
    }
  end
end
