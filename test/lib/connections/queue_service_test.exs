defmodule NetSuite.Connections.QueueServiceTest do
  use ExUnit.Case, async: true

  @module NetSuite.Connections.QueueService

  test "#next_in_line returns free_connection if one exists" do
    assert @module.next_in_line([1,2,3], [1,2]) == 3
  end

  test "#next_in_line returns least_engaged if no free conn exists" do
    assert @module.next_in_line([1,2,3], [1,2,3]) == 1
    assert @module.next_in_line([1,2,3], [1,2,1,3]) == 2
    assert @module.next_in_line([1,2,3], [1,2,3,1,2]) == 3
  end

  test "#next_in_line handles case with only one connection in pool, free" do
    assert @module.next_in_line([1], []) == 1
  end

  test "#next_in_line handles case with only one connection in pool, engaged" do
    assert @module.next_in_line([1], [1]) == 1
  end

  test "#cycle_pool returns a list with all the same elements" do
    pool = [1,2,3,4,5]
    conn = 3
    result = @module.cycle_pool(pool, conn)

    for conn <- pool, do: assert(Enum.member? result, conn)
  end

  test "#cycle_pool moves the connection to the end of the list" do
    pool = [1,2,3,4,5]
    conn = 3

    assert @module.cycle_pool(pool, conn) == [1,2,4,5,3]
  end

  test "#cycle_pool handles pool with single connection" do
    assert @module.cycle_pool([1], 1) == [1]
  end

  test "#free_connection returns first non-engaged connection" do
    assert @module.free_connection([5,2,3,4], [5,2]) == 3
  end

  test "#free_connection handles when there are no engaged connections" do
    assert @module.free_connection([5,2,3,4], []) == 5
  end

  test "#free_connection handles when every connection is engaged" do
    assert @module.free_connection([5,2], [5,2]) == nil
  end

  test "#free_connection is indifferent to order of engaged connections" do
    assert @module.free_connection([5,2], [2,5]) == nil
    assert @module.free_connection([5,2,3,4], [2,3,5]) == 4
  end

  test "#least_engaged_connection handles duplicate pids in engaged" do
    assert @module.least_engaged_connection([1,1,2,1,3,1,3,1]) == 2
  end

  test "#least_engaged_connection breaks ties based on order of engaged" do
    assert @module.least_engaged_connection([4,1,1,1,1,2,3,3]) == 4
  end

  test "#least_engaged_connection handles single engaged connection" do
    assert @module.least_engaged_connection([4]) == 4
    assert @module.least_engaged_connection([4,4,4]) == 4
  end

  test "#least_engaged_connection returns nil when there are no engaged conns" do
    assert @module.least_engaged_connection([]) == nil
  end
end
