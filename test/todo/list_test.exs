defmodule Todo.ListTest do
  use ExUnit.Case

  alias Todo.List
  alias Todo.Item
  alias Todo.Cache

  setup do
    on_exit fn -> Cache.clear end

    {:ok, list} = List.start_link("Home")
    {:ok, list: list}
  end

  test ".items returns the todos on the list", %{list: list} do
     assert List.items(list) == []
  end

  test ".add adds an item to the list", %{list: list} do
    item = Item.new("Some test")
    List.add(list, item)

    assert List.items(list) == [item]
  end

  test ".update can mark an item complete", %{list: list} do
    item = Item.new("Complete task")
    List.add(list, item)

    # Update item
    item = %{item | description: "new", completed: true }
    List.update(list, item)

    assert List.items(list) == [item]
  end

end
