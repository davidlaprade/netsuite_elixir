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

  test "can cast multiple functions to the same agent"

  test "runs cast functions asynchronously", %{agent: agent} do
    assert :ok == @described_module.cast(agent, make_ref(), fn(_)->
      :timer.sleep(1000000000000000000000000000)
    end)
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
    assert {:error, %ArithmeticError{message: "bad argument in arithmetic
    expression"}} == NetSuite.wait_for_response(ticket)
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
