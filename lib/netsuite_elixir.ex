defmodule NetSuite do
  use Application

  defdelegate config(auth), to: NetSuite.Configuration, as: :set
  defdelegate config, to: NetSuite.Configuration, as: :get

  def start(_type, _args) do
    {:ok, sup}  = NetSuite.Connections.Supervisor.start_link

    {:ok, _pid} = NetSuite.Connections.Pool.start_link
    configs = Application.get_env(:netsuite_elixir, :configs, [])
    for config <- configs, do: NetSuite.Connections.Pool.add(config)

    {:ok, sup}
  end

end
