defmodule NetSuiteTest do
  use ExUnit.Case, async: true

  test "starts workers for each config in the environment" do
    assert Enum.count(NetSuite.Connections.Pool.list) == Enum.count(
      Application.get_env(:netsuite_elixir, :configs, [])
    )
    [{pid, _}] = NetSuite.Connections.Pool.list

    assert NetSuite.Connections.Connection.get_config(pid) ==
      List.first(Application.get_env(:netsuite_elixir, :configs, []))
  end

end
