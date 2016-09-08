defmodule NetSuite.HTTP.Client do

  @behaviour NetSuite.HTTP

  def get(uri, headers) do
    client.start
    client.get(uri, headers)
  end

  def parse({_, response}) do
    {response.status_code, Poison.decode!(response.body)}
  end

  defp client do
    HTTPoison
  end

end
