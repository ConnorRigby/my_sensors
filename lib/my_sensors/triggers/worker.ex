defmodule MySensors.Triggers.Worker do
  use GenServer
  alias MySensors.{Triggers, SensorTrigger, Sensor, Packet}
  use Packet.Constants
  @checkup_ms 10_000

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def init([]) do
    {:ok, %{timer: Process.send_after(self(), :work, 1)}}
  end

  def handle_info(:work, _state) do
    triggers = Triggers.all_triggers()
    {:noreply, nil, {:continue, {:triggers, triggers}}}
  end

  def handle_continue({:triggers, []}, _) do
    {:noreply, Process.send_after(self(), :work, @checkup_ms)}
  end

  def handle_continue({:triggers, [trigger | rest] = _triggers}, state) do
    case Triggers.evaluate(trigger) do
      %Sensor{} = execute ->
        :ok = do_execute(execute, trigger)

      nil ->
        :ok
    end

    {:noreply, state, {:continue, {:triggers, rest}}}
  end

  def do_execute(%Sensor{} = sensor, %SensorTrigger{} = trigger) do
    %Packet{
      ack: false,
      child_sensor_id: sensor.child_sensor_id,
      node_id: sensor.node_id,
      command: @command_SET,
      payload: trigger.payload,
      type: String.to_existing_atom(trigger.value_type)
    }
    |> MySensors.Gateway.write_packet()
  end
end
