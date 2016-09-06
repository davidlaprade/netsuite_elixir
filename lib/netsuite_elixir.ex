defmodule NetSuite do
end

defmodule NetSuite.Configuration do
  @doc """
    usage %NetSuite.Configuration{email: "me@gmail.com", password: "..."}
  """

  defstruct email: "",
            password: "",
            production: true,
            wsdl: "",
            api_version: "2012_1"

end
