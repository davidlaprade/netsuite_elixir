defmodule NetSuite.Connections.Connection do

  @moduledoc """
  Holds config state and yeilds it to calls
  """

  @receiver NetSuite.Connections.Receiver

  def start_link(config) when is_map(config) do
    Agent.start_link(fn -> config end, [])
  end

  def update_config(pid, new_config) when is_map(new_config) do
    Agent.update(pid, fn(_) -> new_config end)
  end

  def get_config(pid), do: Agent.get(pid, &(&1))

end
