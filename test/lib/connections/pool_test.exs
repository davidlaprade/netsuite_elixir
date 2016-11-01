defmodule NetSuite.Connections.PoolTest do
  use ExUnit.Case, async: false

  @described_module NetSuite.Connections.Pool

  test "adds connections" do
    init = Supervisor.count_children(NetSuite.Connections.Supervisor)
    pid = @described_module.add(%{fake: :config})
    new = Supervisor.count_children(NetSuite.Connections.Supervisor)

    assert new.workers == init.workers + 1
    assert NetSuite.Connections.Connection.get_config(pid) == %{fake: :config}
  end

  test "lists connection PIDs and configs" do
    pid = @described_module.add(config=%{make: :believe})

    {list_pid, list_config} = List.first(@described_module.list)
    assert is_pid(list_pid)
    assert pid==list_pid
    assert config==list_config
  end

  test "cycles through connection list as it makes API calls" do
    @described_module.add(%{fake: :config})
    pid = @described_module.add(config=%{make: :believe})
    {list_pid, list_config} = List.first(@described_module.list)
    assert pid==list_pid
    assert config==list_config

    {:ok, _} = NetSuite.call(fn(_) -> 42 end)

    {list_pid, list_config} = List.last(@described_module.list)
    assert pid==list_pid
    assert config==list_config
  end

  test "removes connections" do
    pid = @described_module.add(%{fake: :config})
    @described_module.remove(pid)

    refute Process.alive?(pid)
  end

  test "keeps track of connections when they go down" do
    initial = @described_module.list
    pid = @described_module.add(%{fake: :config})
    refute @described_module.list == initial
    @described_module.remove(pid)

    assert @described_module.list == initial
  end

end
