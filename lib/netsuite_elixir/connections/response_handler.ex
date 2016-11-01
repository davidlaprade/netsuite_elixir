defmodule NetSuite.Connections.ResponseHandler do
  use GenEvent

  def handle_event({:request_end, {ticket, agent, response}}, responses) when
    is_reference(ticket) and
    is_pid(agent) do
    {:ok, Map.put(responses, ticket, {:finished, agent, response})}
  end

  def handle_event({:request_begin, {ticket, agent}}, responses) when
    is_reference(ticket) and
    is_pid(agent) do
    {:ok, Map.put(responses, ticket, {:pending, agent, nil})}
  end

  def handle_event({:request_error, {ticket, agent, error}}, responses) when
    is_reference(ticket) and
    is_pid(agent) do
    {:ok, Map.put(responses, ticket, {:error, agent, error})}
  end

  def handle_call({:get, ref}, responses) do
    case Map.get(responses, ref) do
      {:finished, _agent, response} -> {:ok, {:ok, response}, Map.delete(responses, ref)}
      {:pending,  _agent, response} -> {:ok, {:pending, nil}, responses}
      {:error,    _agent, error}    -> {:ok, {:error, error}, Map.delete(responses, ref)}
      nil ->  {:ok, {:error, {"response not found for reference", ref}}, responses}
    end
  end

  def handle_call(:engaged_connections, responses) do
    agents = Map.keys(responses)
    |> Enum.filter(fn({key, _agent, _}) -> key==:pending end)
    |> Enum.map(fn({_key, agent, _}) -> agent end)
    {:ok, agents, responses}
  end

end
