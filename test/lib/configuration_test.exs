defmodule NetSuiteConfigurationTest do
  use ExUnit.Case, async: true
  # doctest NetSuite.Configuration

  test "it sets and gets the configs" do
    NetSuite.Configuration.set %{
      email:       "bob@gmail.com",
      password:    "secret",
      account:     "TSTDRV1",
      production:  true,
      wsdl:        "wsdl",
      api_version: "2016_2"
    }
    assert NetSuite.Configuration.get == %NetSuite.Configuration{
      email:       "bob@gmail.com",
      password:    "secret",
      account:     "TSTDRV1",
      production:  true,
      wsdl:        "wsdl",
      api_version: "2016_2"
    }
  end

  test "it sets default configs if nil is given" do
    NetSuite.Configuration.set %{
      email:       "bob@gmail.com",
      password:    "secret",
      account:     "TSTDRV1",
      production:  nil,
      wsdl:        nil,
      api_version: nil
    }
    assert NetSuite.Configuration.get == %NetSuite.Configuration{
      email:       "bob@gmail.com",
      password:    "secret",
      account:     "TSTDRV1",
      production:  false,
      wsdl:        "https://webservices.netsuite.com",
      api_version: "2012_2"
    }
  end

  test "it aliases get and set with NetSuite"

  test "it only sets provided configs and leaves others alone" do
    old_config = NetSuite.Configuration.get
    NetSuite.Configuration.set %{ email: "bob@gmail.com" }

    assert Enum.all?(Map.keys(%NetSuite.Configuration{}), fn(key) -> do
      if key==:email do
      else
      end
    end)
    assert NetSuite.Configuration.get.email == "bob@gmail.com"
    assert NetSuite.Configuration.get.password == old_password
  end

  test "it raises an argument error if not given a map" do

  end

  test "it returns :ok and configs if configs are set"
  test "it returns :error when passed an unsupported config"

end
