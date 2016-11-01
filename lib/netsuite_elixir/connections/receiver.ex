defmodule NetSuite.Connections.Receiver do

  @handler NetSuite.Connections.ResponseHandler

  def start_link do
    {:ok, pid} = GenEvent.start_link(name: __MODULE__)
    # should the handler be added here?
    :ok = GenEvent.add_mon_handler(__MODULE__, @handler, %{})
    {:ok, pid}
  end

  def get(ticket) when is_reference(ticket) do
    GenEvent.call(__MODULE__, @handler, {:get, ticket})
  end

  def engaged_connections do
    GenEvent.call(__MODULE__, @handler, :engaged_connections)
  end

end
