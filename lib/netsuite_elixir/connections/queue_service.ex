defmodule NetSuite.Connections.QueueService do

  @moduledoc """
  Functions for determining which connection should process the next
  NetSuite request
  """

  @doc """
  Determine which connection in the pool should process the next request
  """
  @spec next_in_line( pool :: [pid] ) :: pid
  def next_in_line(pool,
    engaged \\ NetSuite.Connections.Receiver.engaged_connections) do
    free_connection(pool, engaged) || least_engaged_connection(engaged)
  end

  @doc """
  Removes the conn from the pool and cycles it to the end
  """
  @spec cycle_pool( pool :: [pid], pid ) :: [pid]
  def cycle_pool(pool, conn) do
    pool
    |> List.delete(conn)
    |> List.insert_at(-1, conn)
  end

  def free_connection(pool, engaged) do
    Enum.filter(pool, &(!Enum.member?(engaged, &1)))
    |> List.first
  end

  def least_engaged_connection(engaged) do
    Enum.uniq(engaged)
    |> Enum.sort_by(&(Enum.count(engaged, fn(x)-> x==&1 end)), &<=/2)
    |> List.first
  end
end
