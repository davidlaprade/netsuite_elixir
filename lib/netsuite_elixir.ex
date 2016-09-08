defmodule NetSuite do

  defdelegate config(auth), to: NetSuite.Configuration, as: :set
  defdelegate config, to: NetSuite.Configuration, as: :get

end
