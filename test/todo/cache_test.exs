defmodule Todo.CacheTest do
  use ExUnit.Case

  alias Todo.Cache
  alias Todo.List

  setup do
    Cache.clear
    list = List.new("Test")
    Cache.save(list)

    {:ok, list: list}
  end

  test ".save adds a list to the cache" do
    info = :ets.info(Cache)

    assert info[:size] == 1
  end

  test ".delete deletes a list from the cache", %{list: list} do
    Cache.delete(list)

    assert :ets.info(Cache)[:size] == 0
  end

  test ".find returns a list from the cache", %{list: list} do
    assert list == Cache.find(list.name)
  end

  test ".find returns nil for not found list" do
    assert nil == Cache.find("no-list")
  end

  test ".list_names returns a list of list names" do
    list = List.new("Test1")
    Cache.save(list)
    assert ["Test1", "Test"] == Cache.list_names
  end

  test ".clear removes all lists from the cache", %{list: list} do
    Cache.clear
    refute Cache.find(list.name)
  end
end
