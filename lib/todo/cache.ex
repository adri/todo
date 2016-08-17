defmodule Todo.Cache do
  use GenServer
  import String, only: [to_atom: 1]

  ## Public API

  def save(list) do
    :ets.insert(__MODULE__, {to_atom(list.name), list})
  end

  def delete(list) do
    :ets.delete(__MODULE__, to_atom(list.name))
  end

  def find(name) do
    case :ets.lookup(__MODULE__, to_atom(name)) do
      [{_id, list}] -> list
      [] -> nil
    end
  end

  def list_names() do
    # Find all keys and map each key to a string
    :ets.match(__MODULE__, {:"$1", :"_"})
      |> Enum.map(&(to_string(List.first(&1))))
  end

  def clear() do
    :ets.delete_all_objects(__MODULE__)
  end

  ## GenServer API

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    table = :ets.new(__MODULE__, [:named_table, :public])

    {:ok, table}
  end

end
