defmodule NetSuite.Configuration do

  @doc ~S"""
  Set/get the credentials used to make API requests.

  ## Usage:

    iex> NetSuite.Configuration.set %{email: "bob@gmail.com", password: "muffins"}
    :ok
    iex> NetSuite.Configuration.get
    %{email: "bob@gmail.com", password: "muffins"}
    iex> NetSuite.Configuration.get.email
    "bob@gmail.com"

    iex> NetSuite.Configuration.set %{ password: "muffins", shmemail: "" }
    ** (RuntimeError) unsupported config: shmemail

  """

  @allowed [
    :email,
    :password,
    :production,
    :account,
    :wsdl,
    :api_version
  ]

  def get, do: Application.get_env(:netsuite_elixir, :config)

  def set(config) do
    Enum.each(Map.keys(config), fn(key) ->
      if !Enum.member?(@allowed, key), do: raise "unsupported config: #{key}"
    end)

    Application.put_env(:netsuite_elixir, :config, config)
  end

end
