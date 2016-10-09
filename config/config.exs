use Mix.Config

config :netsuite_elixir, :configs, [
  %{
    email:        System.get_env("NETSUITE_EMAIL"),
    password:     System.get_env("NETSUITE_PASSWORD"),
    account:      System.get_env("NETSUITE_ACCOUNT"),
    production:   System.get_env("NETSUITE_PRODUCTION") == "true",
    wsdl:         System.get_env("NETSUITE_WSDL") || "https://webservices.netsuite.com",
    api_version:  System.get_env("NETSUITE_API") || "2012_1"
  }
]
