defmodule NetSuite.HTTP.Client do

  @behaviour NetSuite.HTTP

  def get(uri, headers) do
    client.start
    parse_response client.get(uri, headers)
  end

  defp client do
    HTTPoison
  end

  defp parse_response({_, response}) do
    {response.status_code, Poison.decode!(response.body)}
  end

end
