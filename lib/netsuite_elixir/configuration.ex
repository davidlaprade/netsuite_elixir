defmodule NetSuite.Configuration do

  @doc ~S"""
  Set/get the credentials used to make API requests.

  ## Usage:

    iex> NetSuite.Configuration.get
    %NetSuite.Configuration{account: "TSTDRV1", api_version: "2016_2", email:
      "bob@gmail.com", password: "secret", production: true, wsdl: "wsdl"}

    iex> NetSuite.Configuration.get.email
    "bob@gmail.com"

    iex> NetSuite.Configuration.get.account
    "TSTDRV1"

    iex> NetSuite.Configuration.set %{email: "new email", password: "new password"}
    [:ok, %NetSuite.Configuration{account: "TSTDRV1", api_version: "2016_2", email:
      "new email", password: "new password"", production: true, wsdl: "wsdl"}

    iex> NetSuite.Configuration.set %{ password: "muffins", shmemail: "" }
    [:error, "unsupported config: shmemail"]

  """

  @default_wsdl "https://webservices.netsuite.com"
  @default_api "2012_2"

  defstruct email: "",
    password:      "",
    production:    false,
    account:       "",
    wsdl:          @default_wsdl,
    api_version:   @default_api

  # TODO move this over to OTP, get things started...
  def get do
    %__MODULE__{
      email:        format_email(Application.get_env :netsuite_elixir, :email),
      password:     format_password(Application.get_env :netsuite_elixir, :password),
      account:      format_account(Application.get_env :netsuite_elixir, :account),
      production:   format_environment(Application.get_env :netsuite_elixir, :production),
      wsdl:         format_wsdl(Application.get_env :netsuite_elixir, :wsdl),
      api_version:  format_api(Application.get_env :netsuite_elixir, :api_version)
    }
  end

  def set(config) when is_map(config) do
    allowed_keys = Map.keys(%__MODULE__{})
    Enum.each(Map.keys(config), fn(key) ->
      if Enum.member?(allowed_keys, key) do
        Application.put_env(:netsuite_elixir, key, Map.get(config, key))
      else
        [:error, "unsupported config: #{key}"]
      end
    end)
    [:ok, get]
  end
  def set(_), do: raise ArgumentError.exception("set configuration with a map")

  defp format_password(input), do: input

  defp format_email(input), do: input

  defp format_environment(input) when is_binary(input), do: input == "true"
  defp format_environment(input) when is_boolean(input), do: input

  defp format_account(input), do: input

  defp format_wsdl(input) do
    input || @default_wsdl
  end

  defp format_api(input) do
    input || @default_api
  end

end
