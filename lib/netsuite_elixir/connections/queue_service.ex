defmodule NetSuite.Connections.QueueService do

  @doc """
  Determine which connection in the pool should process the next request
  """
  @spec next_in_line( pool :: [pid] ) :: pid
  def next_in_line(pool) do
    engaged = NetSuite.Connections.Receiver.engaged_connections
    non_engaged_connection(pool, engaged) || least_engaged_connection(engaged)
  end

  defp non_engaged_connection(pool, engaged) do
    Enum.filter(pool, &(!Enum.member?(engaged, &1))
    |> List.first
  end

  defp least_engaged_connection(engaged) do
    Enum.uniq(engaged)
    |> Enum.sort_by(&(Enum.count(engaged, fn(x)-> x==&1 end)))
    |> List.first
  end
end
