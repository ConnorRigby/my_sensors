defmodule MySensors.TriggersTest do
  use ExUnit.Case
  alias MySensors.{Context, Packet}
  use Packet.Constants
  alias MySensors.Triggers

  describe "trigger evaluation" do
    test "time comparison" do
      n0 = node_()
      s0 = sensor(n0, 0, @sensor_TEMP)
      s1 = sensor(n0, 1, @sensor_TEMP)

      {:ok, trigger} =
        Triggers.new_trigger(s0, s1, %{
          value_type: to_string(@value_STATUS),
          value_comparison: 10,
          value_condition: ">",
          payload: 1,
          name: Faker.Pokemon.name(),
          # doesn't matter for this test
          valid_from_datetime: dt(1, 1, 2018, 1, 1),
          # doesn't matter for this test,
          valid_to_datetime: dt(1, 1, 2018, 1, 1),
          valid_to_time: time(10, 15),
          valid_from_time: time(10, 20)
        })

      # Check a minute before the time
      refute Triggers.evaluate(trigger, dt(1, 1, 2018, 10, 14))

      # Check a minute after the time
      refute Triggers.evaluate(trigger, dt(1, 1, 2018, 10, 16))

      # Check an hour before the time
      refute Triggers.evaluate(trigger, dt(1, 1, 2018, 09, 15))

      # Check an hour after the time
      refute Triggers.evaluate(trigger, dt(1, 1, 2018, 11, 15))
    end

    defp node_(params \\ %{}) do
      {:ok, node} = Context.new_node(params)
      node
    end

    defp sensor(node, child_sensor_id, type) do
      sensor_packet = %Packet{
        node_id: node.id,
        child_sensor_id: child_sensor_id,
        type: type,
        command: @command_PRESENTATION
      }

      {:ok, sensor} = Context.save_sensor(sensor_packet)
      sensor
    end

    defp dt(month, day, year, hour, minute) do
      %DateTime{
        month: month,
        day: day,
        year: year,
        hour: hour,
        minute: minute,
        second: 0,
        time_zone: "Etc/UTC",
        std_offset: 0,
        utc_offset: 0,
        zone_abbr: "UTC"
      }
    end

    defp time(hour, minute, second \\ 0) do
      {:ok, t} = Time.new(hour, minute, second)
      t
    end
  end
end
