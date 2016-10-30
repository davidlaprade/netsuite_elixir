defmodule NetSuite.Rest.Roles do

  @endpoint "/roles"

  @doc """
  Fetches all roles associated with the user's credentials
  using the next available connection in the pool.
  Returns {:ok, <ticket>} to lookup the response later
  See get/2 for an example response
  """
  @spec get :: {atom, reference}
  def get, do: NetSuite.call_async(&(get &1))

  @doc """
  Fetches all roles associated with the provided credentials
  Blocks the current process until the call finishes

  Example response:
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
  def get(config, client \\ NetSuite.HTTP.Client ) do
    response = client.get(
      NetSuite.Rest.API.uri(@endpoint, config.production),
      NetSuite.Rest.API.auth_header(config.email, config.password)
    )
    client.parse(response)
  end

end
