defmodule NetSuite.Connections.ConnectionTest do
  use ExUnit.Case, async: true

  @described_module NetSuite.Connections.Connection

  defp wait_for_response(ticket) do
    case NetSuite.Connections.Receiver.get(ticket) do
      {:pending, nil} -> wait_for_response(ticket)
      response      -> response
    end
  end

  setup do
    {:ok, pid} = @described_module.start_link(%{my: :config})
    {:ok, %{agent: pid}}
  end

  test "stores configs", %{agent: agent} do
    assert @described_module.get_config(agent) == %{my: :config}
  end

  test "updates configs", %{agent: agent} do
    @described_module.update_config(agent, %{new: :config})
    assert @described_module.get_config(agent) == %{new: :config}
  end

end
