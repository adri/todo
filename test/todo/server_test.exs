defmodule Todo.ServerTest do
  use ExUnit.Case

  alias Todo.Server
  alias Todo.Cache

  setup do
    on_exit fn ->
      Server.lists |> Enum.each(&(Server.delete_list/1))
      Cache.clear
    end
  end

  test ".init loads lists from cache" do
    Server.add_list("Home")
    Server.add_list("Work")

    # Kill process
    Supervisor.terminate_child(Todo.Supervisor, Server)
    {:ok, _} = Supervisor.restart_child(Todo.Supervisor, Server)

    # Verify new process
    counts = Supervisor.count_children(Server)
    assert counts.active == 2
  end

  test ".add_list adds a new supervised todo list" do
    Server.add_list("Home")
    Server.add_list("Work")

    counts = Supervisor.count_children(Server)
    assert counts.active == 2
  end

  test ".find_list finds a list by name" do
    Server.add_list("Home")
    list = Server.find_list("Home")

    assert is_pid(list)
  end

  test ".delete_list delets a list by name" do
    Server.add_list("delete-me")
    Server.delete_list(Server.find_list("delete-me"))

    counts = Supervisor.count_children(Server)

    assert Server.find_list("delete-me") == nil
    assert counts.active == 0
  end

end
