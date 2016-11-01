defmodule NetSuite.Connections.ResponseHandler do
  use GenEvent

  def handle_event({:request_end, {ticket, conn, response}}, responses) when
    is_reference(ticket) and
    is_pid(conn) do
    {:ok, Map.put(responses, ticket, {:finished, conn, response})}
  end

  def handle_event({:request_begin, {ticket, conn}}, responses) when
    is_reference(ticket) and
    is_pid(conn) do
    {:ok, Map.put(responses, ticket, {:pending, conn, nil})}
  end

  def handle_event({:request_error, {ticket, conn, error}}, responses) when
    is_reference(ticket) and
    is_pid(conn) do
    {:ok, Map.put(responses, ticket, {:error, conn, error})}
  end

  def handle_call({:get, ref}, responses) do
    case Map.get(responses, ref) do
      {:finished, _conn, response} -> {:ok, {:ok, response}, Map.delete(responses, ref)}
      {:pending,  _conn, response} -> {:ok, {:pending, nil}, responses}
      {:error,    _conn, error}    -> {:ok, {:error, error}, Map.delete(responses, ref)}
      nil ->  {:ok, {:error, {"response not found for reference", ref}}, responses}
    end
  end

  def handle_call(:engaged_connections, responses) do
    connections = Map.values(responses)
                  |> Enum.filter(fn({key, _connection, _}) -> key==:pending end)
                  |> Enum.map(fn({_key, connection, _}) -> connection end)
    {:ok, connections, responses}
  end

end
