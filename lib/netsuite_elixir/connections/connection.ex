defmodule NetSuite.Connections.Connection do

  @moduledoc """
  Holds config state and yeilds it to calls
  """

  @receiver NetSuite.Connections.Receiver

  def start_link(config) when is_map(config) do
    Agent.start_link(fn -> config end, [])
  end

  def update_config(conn, new_config) when is_map(new_config) do
    Agent.update(conn, fn(_) -> new_config end)
  end

  def get_config(conn), do: Agent.get(conn, &(&1))

  @doc """
    Makes the NS API call asynchronously, exposing the connection's
    configuration as a callback. Notifies the Receiver when it
    starts and finishes requests
  """
  def cast(conn, ticket, netsuite_call) when
    is_pid(conn) and
    is_reference(ticket) and
    is_function(netsuite_call) do

    GenEvent.notify(@receiver, {:request_begin, {ticket, conn}})

    Agent.cast(conn, fn(config)->
      try do
        response = netsuite_call.(config)
        GenEvent.notify(@receiver, {:request_end, {ticket, conn, response}})
      rescue
        e in _ -> GenEvent.notify(@receiver, {:request_error, {ticket, conn, e}})
      end

      config
    end)
  end

end
