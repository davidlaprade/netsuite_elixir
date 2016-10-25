defmodule NetSuite do
  use Application

  defdelegate config(auth), to: NetSuite.Configuration, as: :set
  defdelegate config, to: NetSuite.Configuration, as: :get

  defdelegate call(funct), to: NetSuite.Connections.Pool, as: :queue
  defdelegate get(ticket), to: NetSuite.Connections.Pool, as: :response

  def start(_type, _args) do
    {:ok, sup}  = NetSuite.Connections.Supervisor.start_link

    # TODO the receiver should be supervised
    {:ok, _pid} = NetSuite.Connections.Receiver.start_link

    {:ok, _pid} = NetSuite.Connections.Pool.start_link
    configs = Application.get_env(:netsuite_elixir, :configs, [])
    for config <- configs, do: NetSuite.Connections.Pool.add(config)

    {:ok, sup}
  end

end
