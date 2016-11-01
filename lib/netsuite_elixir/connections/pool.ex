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

  @doc "list all connections in the pool"
  @spec list :: [{pid, map}]
  def list do
    GenServer.call(__MODULE__, :list)
  end

  @doc "queue a netsuite call for asynchronous processing"
  @spec queue(fun) :: atom
  def queue(netsuite_call) when is_function(netsuite_call) do
    GenServer.call(__MODULE__, {:queue, netsuite_call})
  end

  @doc "fetch the netsuite response from the a queued request"
  @spec response(reference) :: { atom, any }
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

  def handle_call({:queue, netsuite_call}, _from, {connections, refs}) do
    NetSuite.Connections.Connection.cast(
      NetSuite.Connections.QueueService.next_in_line(connections),
      ticket = make_ref(),
      netsuite_call
    )

    # TODO cycle connections

    {:reply, {:ok, ticket}, {connections, refs}}
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
