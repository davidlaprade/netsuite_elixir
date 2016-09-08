defmodule NetSuite.Configuration do

  @moduledoc """
    Set this config before making any API calls

    You can do it manually:

      NetSuite.Configuration.set %{
        email: ...,
        password: ...,
        production: true,
        wsdl: ...,
        api_version: ...
      }

    Or, export the following vars into your shell:

      export NETSUITE_EMAIL=...
      export NETSUITE_PASSWORD=...
      export NETSUITE_PRODUCTION=...
      export NETSUITE_WSDL=...
      export NETSUITE_API=...

    Check your configs at any time with:

      NetSuite.Configuration.get

    Or just:

      NetSuite.config

    Get a specific config:

      NetSuite.config.email

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
