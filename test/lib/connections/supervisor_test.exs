defmodule NetSuite.Connections.SupervisorTest do
  use ExUnit.Case, async: false

  @described_module NetSuite.Connections.Supervisor

  test "spawns connections" do
    init_count = Supervisor.count_children(@described_module).workers
    {:ok, pid} = @described_module.start_connection(%{fake: :config})
    new_count = Supervisor.count_children(@described_module).workers

    assert new_count == init_count + 1
    assert NetSuite.Connections.Connection.get_config(pid) == %{fake: :config}
  end

  test "stops connections" do
    {:ok, pid} = @described_module.start_connection(%{fake: :config})
    old = Supervisor.count_children(@described_module)
    @described_module.sever_connection(pid)
    new = Supervisor.count_children(@described_module)

    assert new.workers == old.workers - 1
  end

  test "restarts connections that are killed" do
    {:ok, child} = @described_module.start_connection(%{my: :connection})
    children = Supervisor.which_children @described_module
    config = NetSuite.Connections.Connection.get_config(child)
    Agent.stop(child)
    new_children = Supervisor.which_children @described_module
    {_, new_child, :worker, _} = Enum.find(new_children, &(!Enum.member?(children, &1)))

    assert Enum.count(children) == Enum.count(new_children)
    assert config == NetSuite.Connections.Connection.get_config(new_child)
  end

end

