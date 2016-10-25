defmodule NetSuite do
  use Application

  def start(_type, _args) do
    {:ok, sup}  = NetSuite.Connections.Supervisor.start_link

    # TODO the receiver should be supervised
    {:ok, _pid} = NetSuite.Connections.Receiver.start_link

    {:ok, _pid} = NetSuite.Connections.Pool.start_link
    configs = Application.get_env(:netsuite_elixir, :configs, [])
    for config <- configs, do: NetSuite.Connections.Pool.add(config)

    {:ok, sup}
  end

  defdelegate config(auth), to: NetSuite.Configuration, as: :set
  defdelegate config, to: NetSuite.Configuration, as: :get

  @doc """
  Make a NetSuite call asynchronously using the next connection in the pool
  """
  @spec call_async(fun) :: {atom, reference}
  defdelegate call_async(funct), to: NetSuite.Connections.Pool, as: :queue

  @spec get(reference) :: {atom, any}
  defdelegate get(ticket), to: NetSuite.Connections.Pool, as: :response

  @doc """
  Make a NetSuite call using the next connection in the connection pool
  Block the current process until the call finishes

  Returns a List, the first member of which is a status code:
    :ok      -> the request was made and ran without error
    :error   -> there was an error processing the request
    :pending -> the request is still being made, check back later

  The second member of the return value depends on the first:
    :ok      -> the return value of the netsuite_call passed in
    :error   -> an error description or struct
    :pending -> nil
  """
  @spec call(fun) :: {atom, any}
  def call(netsuite_call) when is_function(netsuite_call) do
    {:ok, ticket} = call_async(netsuite_call)
    wait_for_response(ticket)
  end

  defp wait_for_response(ticket) do
    case get(ticket) do
      {:pending, _response} -> wait_for_response(ticket)
      response              -> response
    end
  end
end
