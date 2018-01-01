defmodule MySensors.Repo do
  @moduledoc "Repository for local MySensors Data."
  alias MySensors.Node
  require Logger
  def start_link do
    GenServer.start_link(__MODULE__, [], [name: __MODULE__])
  end

  def init([]) do
    with :ok <- create_schema(),
    :ok <- :mnesia.start(),
    :ok <- setup_table(Node),
    :ok <- :mnesia.wait_for_tables([Node], 1500)
    do
      {:ok, :no_state, :hibernate}
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
    keys = module.keys()
    tables = :mnesia.system_info(:tables)
    if module not in tables do
      :mnesia.create_table(module, [attributes: keys, type: :ordered_set])
    else
      {:atomic, :ok}
    end
    |> case do
      {:atomic, :ok} ->
        case :mnesia.table_info(module,:attributes) do
          list when list != keys ->
            Logger.error "struct changed size!"
            exit(:wuhoh)
          ^keys -> :ok
        end
      err -> err
    end
  end
end
