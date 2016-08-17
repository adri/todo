defmodule Todo.Server do
  use Supervisor

  alias Todo.Cache
  alias Todo.List

  ## Public API

  def add_list(name) do
    Supervisor.start_child(__MODULE__, [name])
  end

  def find_list(name) do
    Enum.find lists, fn(child) ->
      List.name(child) == name
    end
  end

  def delete_list(list) do
    List.delete(list)
    Supervisor.terminate_child(__MODULE__, list)
  end

  def lists do
    __MODULE__
     |> Supervisor.which_children
     |> Enum.map(fn({_, child, _, _}) -> child end)
  end

  ## Supervisor API

  def start_link do
    server = Supervisor.start_link(__MODULE__, [], name: __MODULE__)

    Cache.list_names
      |> Enum.each(&add_list/1)

    server
  end

  def init(_) do
    children = [
      worker(Todo.List, [], restart: :transient)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end

end
