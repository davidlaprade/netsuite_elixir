defmodule NetSuite.REST.API do

  @production_uri "https://rest.netsuite.com/rest"
  def production_uri, do: @production_uri

  @sandbox_uri    "https://rest.sandbox.netsuite.com/rest"
  def sandbox_uri, do: @sandbox_uri

end
