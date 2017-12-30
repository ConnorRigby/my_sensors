defmodule MySensors.Repo do
  @moduledoc "Repository for local MySensors Data."
  alias MySensors.{Node, Sensor, SensorValue}
  def start_link do
    GenServer.start_link(__MODULE__, [], [name: __MODULE__])
  end

  def init([]) do
    with :ok <- create_schema(),
    :ok <- :mnesia.start(),
    :ok <- setup_table(Node),
    :ok <- setup_table(Sensor),
    :ok <- setup_table(SensorValue)
    do
      {:ok, %{}}
    else
      {:error, reason} -> {:stop, {:error, reason}}
      err -> {:stop, {:error, err}}
    end
  end

  defp create_schema do
    case :mnesia.create_schema([node()]) do
      :ok -> :ok
      {:error, {_, {:already_exists, _}}} -> :ok
      err -> err
    end
  end

  defp setup_table(module) do
    collums = struct(module) |> Map.keys()
    case :mnesia.create_table(module, [attributes: collums]) do
      {:atomic, :ok} -> :ok
      {:aborted, {:already_exists, _}} -> :ok
      {:aborted, reason} -> {:error, reason}
    end
  end
end
