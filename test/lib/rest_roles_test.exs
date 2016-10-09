defmodule TestHelper.HTTP.Client do
  @behaviour NetSuite.HTTP
  def get(uri, headers), do: "response"
  def parse(response), do: "parsed #{response}"
end

defmodule NetSuiteRestRolesTest do
  use ExUnit.Case, async: true

  setup do
    NetSuite.config %{
      email: "fake email",
      password: "secret",
      production: true
    }
    :ok
  end

  test "it gets and parses the API response" do
    roles_response = NetSuite.Rest.Roles.get(
      NetSuite.config,
      TestHelper.HTTP.Client
    )

    assert roles_response == "parsed response"
  end
end

