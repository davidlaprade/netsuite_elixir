defmodule NetSuite.Connections.ResponseHandler do
  use GenEvent

  def handle_event({:request_end, {ref, response}}, responses) do
    {:ok, Map.put(responses, ref, {:finished, response})}
  end

  def handle_event({:request_begin, ref}, responses) do
    {:ok, Map.put(responses, ref, {:pending, nil})}
  end

  def handle_event({:request_error, {ref, error}}, responses) do
    {:ok, Map.put(responses, ref, {:error, error})}
  end

  def handle_call({:get, ref}, responses) do
    case Map.get(responses, ref) do
      {:finished, response} ->  {:ok, {:ok, response}, Map.delete(responses, ref)}
      {:pending, _response} ->  {:ok, {:pending, nil}, responses}
      {:error,    error}    ->  {:ok, {:error, error}, Map.delete(responses, ref)}
      nil ->  {:ok, {:error, {"response not found for reference", ref}}, responses}
    end
  end

end
