defmodule NetSuite.REST.Roles do

  @doc """
    Usage:
    config = %NetSuite.Configuration{...}
    NetSuite.REST.Roles.get(config)

    Returns:
    {
      :ok,
      [
        %{
            "account" => %{
              "internalId" => "TSTDRVxxxx",
              "name" => "Honeycomb Mfg SDN (Leading)"
            },
            "dataCenterURLs" => %{
              "restDomain" => "https://rest.na1.netsuite.com",
              "systemDomain" => "https://system.na1.netsuite.com",
              "webservicesDomain" => "https://webservices.na1.netsuite.com"
            },
            "role" => %{
              "internalId" => 3,
              "name" => "Administrator"
            }
         },
         ...
      ]
    }
  """

  @endpoint "/roles"

  def get(config) do
    HTTPoison.start
    parse_response HTTPoison.get(
      uri(config.production),
      auth_header(config.email, config.password)
    )
  end

  defp auth_header(email, password) do
    header = "NLAuth nlauth_email=#{encode email}," <>
      "nlauth_signature=#{encode password}"
    %{ "Authorization" => header }
  end

  defp encode(string) do
    URI.encode(string, &(!URI.char_reserved? &1))
  end

  defp parse_response({code, response}) do
    {response.status_code, Poison.decode!(response.body)}
  end

  defp uri(production) do
    if production do
      NetSuite.REST.API.production_uri <> @endpoint
    else
      NetSuite.REST.API.sandbox_uri <> @endpoint
    end
  end

end
