defmodule NetSuite.Connections.Supervisor do
  use Supervisor

  @moduledoc """
  Supervises and restarts the NetSuite.Connections.Connection processes
  """

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    supervise(
      [worker(NetSuite.Connections.Connection, [])],
      strategy: :simple_one_for_one
    )
  end

  def start_connection(config) when is_map(config) do
    Supervisor.start_child(__MODULE__, [config])
  end

  def sever_connection(pid) when is_pid(pid) do
    Supervisor.terminate_child(__MODULE__, pid)
  end

end
