defmodule MySensors.Triggers do
  require Logger
  alias MySensors.{Repo, Sensor, SensorTrigger, SensorValue}
  import Ecto.Query

  @doc """
  Creates a new trigger. This trigger will `execute` `execute`'s sensor based on
  `executor`s value.

  required params:
    * `name` - name of trigger
    * `valid_from_datetime`
    * `valid_to_datetime`
    * `value_condition` (float) value of `executor` that will trigger `executee`
  """
  @spec new_trigger(Sensor.t(), Sensor.t(), map) :: {:ok, SensorTrigger.t()} | {:error, term}
  def new_trigger(%Sensor{} = executor, %Sensor{} = executee, params) do
    %SensorTrigger{}
    |> SensorTrigger.changeset(params)
    |> Ecto.Changeset.put_assoc(:executor_sensor, executor)
    |> Ecto.Changeset.put_assoc(:executee_sensor, executee)
    |> Repo.insert()
  end

  @doc "Returns all triggers needing to be processed."
  # TODO(Connor) a well crafted query can probably eliminate the first part of
  # evaluate/2
  @spec all_triggers() :: [SensorTrigger.t()]
  def all_triggers() do
    Repo.all(SensorTrigger)
    |> Repo.preload([:executor_sensor, :executee_sensor])
  end

  @doc """
  Evaluates a SensorTrigger against a time. 
  Checks 
    * valid_from_time
    * valid_to_time
    * valid_from_datetime
    * valid_to_datetime
  in that order.
  """
  def evaluate(%SensorTrigger{} = trigger, now \\ nil) do
    now = now || DateTime.utc_now()

    with {:valid_from_t, :gt} <-
           {:valid_from_t, DateTime.to_time(now) |> Time.compare(trigger.valid_from_time)},
         {:valid_to_t, :lt} <-
           {:valid_to_t, DateTime.to_time(now) |> Time.compare(trigger.valid_to_time)},
         {:valid_from_dt, :gt} <-
           {:valid_from_dt, DateTime.compare(now, trigger.valid_from_datetime)},
         {:valid_to_dt, :lt} <- {:valid_to_dt, DateTime.compare(now, trigger.valid_to_datetime)} do
      Logger.debug("#{trigger.name} ready to be evaluated")
      evaluate_sensor_value(trigger)
    else
      {field, reason} ->
        Logger.debug("#{trigger.name} not ready to be evaluated: in#{field}: #{reason}")
        nil
    end
  end

  @doc "Evaluates a SensorTrigger versus the latest SensorValue stored for a Sensor"
  @spec evaluate_sensor_value(SensorTrigger.t()) :: Sensor.t() | false
  def evaluate_sensor_value(%SensorTrigger{} = trigger) do
    val =
      Repo.one(
        from(sv in SensorValue,
          where: sv.sensor_id == ^trigger.executor_sensor.id,
          limit: 1,
          select: sv.value
        )
      ) || false

    val &&
      case trigger.value_condition do
        ">" -> val > trigger.value_comparison && trigger.executee_sensor
        ">=" -> val >= trigger.value_comparison && trigger.executee_sensor
        "<" -> val < trigger.value_comparison && trigger.executee_sensor
        "<=" -> val <= trigger.value_comparison && trigger.executee_sensor
        "==" -> val == trigger.value_comparison && trigger.executee_sensor
        "!=" -> val != trigger.value_comparison && trigger.executee_sensor
      end
  end
end
