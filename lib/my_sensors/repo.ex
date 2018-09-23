defmodule MySensors.Repo do
  @moduledoc "Repository for local MySensors Data."
  require Logger
  use GenServer

  defstruct [:dbname, :db, :statements]
  alias MySensors.Repo, as: State

  @opaque db :: {:connection, reference(), reference()}
  @opaque stmt :: {:statement, reference(), db}

  @type uninitialized :: %State{
    db: nil,
    dbname: nil,
    statements: nil,
  }

  @type initialized :: %State{
    db: db(),
    dbname: charlist(),
    statements: %{
      required(:insert_node) => stmt,
      required(:delete_node) => stmt,
      required(:insert_sensor) => stmt,
      required(:insert_sensor_value) => stmt
    }
  }

  def start_link do
    opts = Application.get_env(:my_sensors, __MODULE__, [])
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end
  
  @impl GenServer
  @spec init(Keyword.t()) :: {:ok, uninitialized}
  def init(opts) do
    send(self(), {:configure, opts})
    state = extract_opts(opts)
    {:ok, state}
  end

  @impl GenServer
  def terminate(_reason, state) do
    if state.db do
      _state = close_db(state)
    end
  end

  @impl GenServer
  # only configure if db is initialized
  def handle_info({:configure, opts}, %State{db: nil} = _uninitialized_state) do
    state = extract_opts(opts)
    {:noreply, init_db(state)}
  end

  def handle_info({:configure, opts}, %State{dbname: old_name} = old_state) do
    _noop_state = close_db(old_state)
    %State{dbname: new_name} = new_state = extract_opts(opts)
    File.exists?(old_name) && new_name != ':memory:' && File.cp(old_name, new_name)
    {:noreply, init_db(new_state)}
  end

  @spec extract_opts(Keyword.t()) :: uninitialized()
  defp extract_opts(opts) do
    # Collect default opts.
    dbname = Keyword.get(opts, :database, ':memory:') |> to_charlist()
    %State{
      dbname: dbname,
    }
  end

  @spec init_db(uninitialized) :: initialized
  def init_db(state) do
    {:ok, db} = :esqlite3.open(state.dbname)
    nodes_table = """
    CREATE TABLE IF NOT EXISTS "nodes" (
      "id" INTEGER PRIMARY KEY,
      "battery_level" REAL,
      "protocol" TEXT,
      "sketch_name" TEXT,
      "sketch_version" TEXT,
      "config" TEXT,
      "inserted_at" NAIVE_DATETIME NOT NULL, 
      "updated_at" NAIVE_DATETIME NOT NULL
      )
    """ |> to_charlist()

    sensors_table = """
    CREATE TABLE IF NOT EXISTS "sensors" (
      "id" INTEGER PRIMARY KEY,
      "type" TEXT,
      "inserted_at" NAIVE_DATETIME NOT NULL, 
      "updated_at" NAIVE_DATETIME NOT NULL,
      "node_id" INTEGER,
      FOREIGN KEY(node_id) REFERENCES nodes(id) ON DELETE CASCADE
    )
    """ |> to_charlist()

    sensor_values_table = """
    CREATE TABLE IF NOT EXISTS "sensor_values" (
      "id" INTEGER PRIMARY KEY,
      "type" TEXT,
      "value" TEXT,
      "inserted_at" NAIVE_DATETIME NOT NULL, 
      "updated_at" NAIVE_DATETIME NOT NULL,
      "sensor_id" INTEGER,
      FOREIGN KEY(sensor_id) REFERENCES sensors(id) ON DELETE CASCADE
    )
    """ |> to_charlist()
    :ok = :esqlite3.exec(nodes_table, db)
    :ok = :esqlite3.exec(sensors_table, db)
    :ok = :esqlite3.exec(sensor_values_table, db)

    node_insert_stmt_sql = """
    INSERT INTO nodes VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8)
    """ |> to_charlist()
    {:ok, node_insert_stmt} = :esqlite3.prepare(node_insert_stmt_sql, db)

    node_delete_stmt_sql = """
    DELETE FROM nodes WHERE id = ?1
    """ |> to_charlist()
    {:ok, node_delete_stmt} = :esqlite3.prepare(node_delete_stmt_sql, db)

    sensor_insert_stmt_sql = """
    INSERT INTO sensors VALUES (?1, ?2, ?3, ?4, ?5)
    """ |> to_charlist()
    {:ok, sensor_insert_stmt} = :esqlite3.prepare(sensor_insert_stmt_sql, db)
    
    sensor_value_insert_stmt_sql = """
    INSERT INTO sensor_values VALUES (?1, ?2, ?3, ?4, ?5, ?6)
    """ |> to_charlist()
    {:ok, sensor_value_insert_stmt} = :esqlite3.prepare(sensor_value_insert_stmt_sql, db)
    statements = %{
      node_insert: node_insert_stmt,
      node_delete: node_delete_stmt,
      sensor_insert: sensor_insert_stmt,
      sensor_value_insert: sensor_value_insert_stmt
    }
    %State{state | db: db, statements: statements}
  end

  @spec close_db(initialized()) :: uninitialized()
  defp close_db(%State{} = state) do
    :esqlite3.close(state.db)
    %State{state | db: nil, statements: nil}
  end
end
