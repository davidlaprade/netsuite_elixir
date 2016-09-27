use Mix.Config

config :netsuite_elixir,
  email:       System.get_env("NETSUITE_EMAIL"),
  password:    System.get_env("NETSUITE_PASSWORD"),
  account:     System.get_env("NETSUITE_ACCOUNT"),
  production:  System.get_env("NETSUITE_PRODUCTION"),
  wsdl:        System.get_env("NETSUITE_WSDL"),
  api_version: System.get_env("NETSUITE_API")
