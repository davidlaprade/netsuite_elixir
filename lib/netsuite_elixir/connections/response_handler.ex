defmodule NetSuite.Connections.ResponseHandler do
  use GenEvent

  def handle_event({:end_request, {ref, response}}, responses) do
    {:ok, Map.put(responses, ref, response)}
  end

  def handle_event({:begin_request, ref}, responses) do
    {:ok, Map.put(responses, ref, {:pending, nil})}
  end

  def handle_call({:get, ref}, responses) do
    case Map.get(responses, ref) do
      {:finished, response} ->  {:ok, {:ok, response}, Map.delete(responses, ref)}
      {:error,    error}    ->  {:ok, {:error, error}, Map.delete(responses, ref)}
      {:pending, _response} ->  {:ok, {:pending, nil}, responses}
    end
  end

end
