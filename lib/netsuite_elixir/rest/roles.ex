defmodule NetSuite.Rest.Roles do

  @doc """
    Usage:
    NetSuite.Rest.Roles.get

    Returns:
    {
      200,
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

  def get(config \\ NetSuite.config, client \\ NetSuite.HTTP.Client ) do
    client.get(
      NetSuite.Rest.API.uri(@endpoint, config.production),
      NetSuite.Rest.API.auth_header(config.email, config.password)
    )
  end

end
