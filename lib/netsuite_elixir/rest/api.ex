defmodule NetSuite.Rest.API do

  @production_uri "https://rest.netsuite.com/rest"

  @sandbox_uri    "https://rest.sandbox.netsuite.com/rest"

  @doc ~S"""
  Get the URI for a REST endpoint:

  ## Usage:

    iex> NetSuite.Rest.API.uri("/roles", true)
    "https://rest.netsuite.com/rest/roles"

    iex> NetSuite.Rest.API.uri("/roles", false)
    "https://rest.sandbox.netsuite.com/rest/roles"

  """
  def uri(endpoint, production) do
    (if production, do: @production_uri, else: @sandbox_uri) <> endpoint
  end

  @doc ~S"""
  Get the auth header needed to make a REST request

  ## Usage:

    iex> NetSuite.Rest.API.auth_header("xxxx", "yyyy")
    %{"Authorization" => "NLAuth nlauth_email=xxxx,nlauth_signature=yyyy"}

    iex> NetSuite.Rest.API.auth_header("my+account@gmail.com", "?^&*")
    %{"Authorization" => "NLAuth nlauth_email=my%2Baccount%40gmail.com,nlauth_signature=%3F^%26%2A"}

  """
  def auth_header(email, password) do
    header = "NLAuth nlauth_email=#{encode email}," <>
      "nlauth_signature=#{encode password}"
    %{ "Authorization" => header }
  end

  defp encode(string) do
    URI.encode(string, &(!URI.char_reserved? &1))
  end

end
