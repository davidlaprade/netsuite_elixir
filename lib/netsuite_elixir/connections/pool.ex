defmodule NetSuite.Connections.Pool do
  use GenServer

  @moduledoc """
  A registry of the NetSuite.Connections.Connection processes currently running
  """

  # client -------------------------

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc "add a new connection to the pool"
  def add(config) when is_map(config) do
    GenServer.call(__MODULE__, {:add, config})
  end

  @doc "remove a connection to the pool"
  def remove(pid) when is_pid(pid) do
    GenServer.call(__MODULE__, {:remove, pid})
  end

  @doc " list all connections in the pool as tuples {<pid>, config}"
  def list do
    GenServer.call(__MODULE__, :list)
  end

  def queue(funct) do
    GenServer.call(__MODULE__, {:queue, funct})
  end

  def response(ticket) when is_reference(ticket) do
    GenServer.call(__MODULE__, {:get_response, ticket})
  end

  # server -------------------------

  def init(:ok) do
    connections = [] # list of NetSuite.Connections.Connection's
    refs =        [] # list of connection references
    {:ok, {connections, refs}}
  end

  def handle_call({:add, config}, _from, {connections, refs}) do
    {:ok, pid} = NetSuite.Connections.Supervisor.start_connection(config)
    ref = Process.monitor(pid)
    {:reply, pid, { [pid | connections], [ref | refs]}}
  end

  def handle_call({:remove, connection_pid}, _from, {connections, refs}) do
    NetSuite.Connections.Supervisor.sever_connection(connection_pid)
    {:reply, :ok, {List.delete(connections, connection_pid), refs}}
  end

  def handle_call({:queue, funct}, _from, {connections, refs}) do
    # TODO keep track of which connections are free
    [connection | connections] = connections

    NetSuite.Connections.Connection.cast(connection, ticket = make_ref(), funct)

    # put the connection at the end of the list
    {:reply, {:ok, ticket}, {List.insert_at(connections, -1, connection), refs}}
  end

  def handle_call({:get_response, ticket}, _from, state) do
    {:reply, NetSuite.Connections.Receiver.get(ticket), state}
  end

  def handle_call(:list, _from, {connections, _} = state) do
    {
      :reply,
      Enum.map(
        connections,
        &({&1, NetSuite.Connections.Connection.get_config(&1)})
      ),
      state
    }
  end

  def handle_info({:DOWN, ref, :process, pid, _reason}, {connections, refs}) do
    connections = List.delete(connections, pid)
    refs = List.delete(refs, ref)
    {:noreply, {connections, refs}}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

end
