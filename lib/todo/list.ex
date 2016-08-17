defmodule Todo.List do
  @moduledoc false
  use GenServer

  alias Todo.Cache

  defstruct name: nil, items: []

  ## Public API

  def new(name) do
    %__MODULE__{ name: name }
  end

  def items(list) do
    GenServer.call(list, :items)
  end

  def name(list) do
    GenServer.call(list, :name)
  end

  def delete(list) do
    GenServer.call(list, :name)
  end

  def add(list, item) do
    GenServer.cast(list, {:add, item})
  end

  def update(list, item) do
    GenServer.cast(list, {:update, item})
  end

  ## GenSerer API

  def start_link(name) do
    GenServer.start_link(__MODULE__, name)
  end

  def init(name) do
    state = Cache.find(name) || new(name)
    Cache.save(state)

    {:ok, state}
  end

#  def terminate(_, state) do
#    Cache.delete(state)
#  end

  def handle_call(:items, _from, state) do
    {:reply, state.items, state}
  end

  def handle_call(:delete, _from, state) do
    Cache.delete(state)
    {:reply, state, state}
  end

  def handle_call(:name, _from, state) do
    {:reply, state.name, state}
  end

  def handle_cast({:add, item}, state) do
    state = %{state | items: [item | state.items]}
    Cache.save(state)
    {:noreply, state}
  end

  def handle_cast({:update, item}, state) do
    index = Enum.find_index(state.items, &(&1.id == item.id))
    items = List.replace_at(state.items, index, item)
    state = %{state | items: items}
    Cache.save(state)
    {:noreply, state}
  end
end
