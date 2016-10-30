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
      {:finished, agent, response} ->  {:ok, {:ok, agent, response}, Map.delete(responses, ref)}
      {:pending,  agent, response} ->  {:ok, {:pending, agent, nil}, responses}
      {:error,    agent, error}    ->  {:ok, {:error, agent, error}, Map.delete(responses, ref)}
      nil ->  {:ok, {:error, {"response not found for reference", ref}}, responses}
    end
  end

end
