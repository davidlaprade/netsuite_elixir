defmodule NetSuite.Rest.API do

  @production_uri "https://rest.netsuite.com/rest"

  @sandbox_uri    "https://rest.sandbox.netsuite.com/rest"

  def uri(endpoint, production) do
    (if production, do: @production_uri, else: @sandbox_uri) <> endpoint
  end

  def auth_header(email, password) do
    header = "NLAuth nlauth_email=#{encode email}," <>
      "nlauth_signature=#{encode password}"
    %{ "Authorization" => header }
  end

  defp encode(string) do
    URI.encode(string, &(!URI.char_reserved? &1))
  end

end
