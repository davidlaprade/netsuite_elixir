defmodule NetSuite.Connections.ConnectionTest do
  use ExUnit.Case, async: true

  @described_module NetSuite.Connections.Connection

  setup do
    {:ok, pid} = @described_module.start_link(%{my: :config})
    {:ok, %{agent: pid}}
  end

  test "stores configs", %{agent: agent} do
    assert @described_module.get_config(agent) == %{my: :config}
  end

  test "runs cast functions asynchronously", %{agent: agent} do
    assert :ok == @described_module.cast(agent, make_ref(), fn(_)->
      :timer.sleep(1000000000000000000000000000)
    end)
  end

  defp count_requests_for(agent) do
    Enum.count(NetSuite.Connections.Receiver.engaged_connections, &(&1==agent))
  end

  test "can cast repeatedly to agent without running what's cast", %{agent: agent} do
    sleep = fn(_)-> :timer.sleep(10000) end
    assert count_requests_for(agent) == 0

    assert :ok == @described_module.cast(agent, ref1=make_ref(), sleep)
    assert NetSuite.Connections.Receiver.get(ref1) == {:pending, nil}
    assert count_requests_for(agent) == 1

    assert :ok == @described_module.cast(agent, ref2=make_ref(), sleep)
    assert NetSuite.Connections.Receiver.get(ref1) == {:pending, nil}
    assert NetSuite.Connections.Receiver.get(ref2) == {:pending, nil}
    assert count_requests_for(agent) == 2

    assert :ok == @described_module.cast(agent, ref3=make_ref(), sleep)
    assert NetSuite.Connections.Receiver.get(ref1) == {:pending, nil}
    assert NetSuite.Connections.Receiver.get(ref2) == {:pending, nil}
    assert NetSuite.Connections.Receiver.get(ref3) == {:pending, nil}
    assert count_requests_for(agent) == 3
  end

  test "notifies event reciever when casting functions", %{agent: agent} do
    assert :ok == @described_module.cast(agent, ticket=make_ref(), fn(_)->
      :timer.sleep(1000000000000000000000000000)
    end)
    assert {:pending, nil} == NetSuite.Connections.Receiver.get(ticket)
  end

  test "doesn't crash when there are errors in netsuite_calls", %{agent: agent} do
    buggy_funct = fn(_) -> raise ArithmeticError end
    assert :ok == @described_module.cast(agent, ticket=make_ref(), buggy_funct)
    error = %ArithmeticError{message: "bad argument in arithmetic expression"}
    assert {:error, error } == NetSuite.wait_for_response(ticket)
    assert Process.alive?(agent)
  end

  test "notifies event reciever when cast functions complete", %{agent: agent} do
    assert :ok == @described_module.cast(agent, ticket=make_ref(), fn(_)-> 42 end)

    assert {:ok, 42} == NetSuite.wait_for_response(ticket)
  end

  test "updates configs", %{agent: agent} do
    @described_module.update_config(agent, %{new: :config})
    assert @described_module.get_config(agent) == %{new: :config}
  end

end
