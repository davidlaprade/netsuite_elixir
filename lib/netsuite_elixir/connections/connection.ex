defmodule NetSuite.Connections.Connection do

  @moduledoc """
  Holds config state and yeilds it to calls
  """

  @receiver NetSuite.Connections.Receiver

  def start_link(config) when is_map(config) do
    Agent.start_link(fn -> config end, [])
  end

  def update_config(pid, new_config) when is_map(new_config) do
    Agent.update(pid, fn(_) -> new_config end)
  end

  def get_config(pid), do: Agent.get(pid, &(&1))

  @doc """
    Makes the NS API call asynchronously, exposing the connection's
    configuration as a callback. Notifies the Receiver when it
    starts and finishes requests
  """
  def cast(pid, ticket, netsuite_call) when
    is_pid(pid) and
    is_reference(ticket) and
    is_function(netsuite_call) do

    GenEvent.notify(@receiver, {:begin_request, ticket})

    Agent.cast(pid, fn(config)->
      response = try do
        {:finished, netsuite_call.(config)}
      rescue
        error in _ -> {:error, error}
      end
      GenEvent.notify(@receiver, {:end_request, {ticket, response}})
      config
    end)
  end

end
