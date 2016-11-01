defmodule NetSuite.Connections.ResponseHandlerTest do
  use ExUnit.Case, async: true

  @module NetSuite.Connections.ResponseHandler

  defp spawn_process, do: Process.spawn(fn()->42end, [])

  setup do
    ref = make_ref()
    {:ok, %{ref: ref}}
  end

  test "handle_event :request_begin adds to current state", %{ref: ref} do
    {:ok, new_state} = @module.handle_event({:request_begin, {ref,
        pid=spawn_process}}, %{})

    assert new_state == %{ref => {:pending, pid, nil}}
  end

  test "handle_event :request_end writes over current state", %{ref: ref} do
    state = %{ref => {:pending, pid=spawn_process, nil}}
    {:ok, new_state} = @module.handle_event({:request_end, {ref, pid, 42}}, state)

    assert new_state == %{ref => {:finished, pid, 42}}
  end

  test "handle_event :request_error writes over current state", %{ref: ref} do
    state = %{ref => {:pending, pid=spawn_process, nil}}
    {:ok, new_state} = @module.handle_event({:request_error, {ref, pid, :blah}}, state)

    assert new_state == %{ref => {:error, pid, :blah}}
  end

  test "handle_call :get handles missing ticket", %{ref: ref} do
    state = %{fake: :response}
    {:ok, reply, new_state} = @module.handle_call({:get, ref}, state)

    assert reply == {:error, {"response not found for reference", ref}}
    assert new_state == state
  end

  test "handle_call :get does not delete pending requests", %{ref: ref} do
    state = %{ref => {:pending, spawn_process, nil}}
    {:ok, reply, new_state} = @module.handle_call({:get, ref}, state)

    assert reply == {:pending, nil}
    assert new_state == state
  end

  test "handle_call :get deletes finished requests", %{ref: ref} do
    state = %{ref => {:finished, spawn_process, 42}}
    {:ok, reply, new_state} = @module.handle_call({:get, ref}, state)

    assert reply == {:ok, 42}
    assert new_state == %{}
  end

  test "handle_call :get deletes failed requests", %{ref: ref} do
    state = %{ref => {:error, spawn_process, %ArithmeticError{message: 42}}}
    {:ok, reply, new_state} = @module.handle_call({:get, ref}, state)

    assert reply == {:error, %ArithmeticError{message: 42}}
    assert new_state == %{}
  end

  test "handle_call :engaged_connections returns :ok" do
    {response, _, _} = @module.handle_call(:engaged_connections, %{})

    assert response == :ok
  end

  test "handle_call :engaged_connections persists process state", %{ref: ref} do
    state_in = %{ref => {:finished, self, {:ok, "awesome"}}}
    {_, _, state_out} = @module.handle_call(:engaged_connections, state_in)

    assert state_out == state_in
  end

  test "handle_call :engaged_connections returns a list of pids", %{ref: ref} do
    state = %{ref => {:pending, self, nil}}
    {_, reply, _} = @module.handle_call(:engaged_connections, state)

    assert reply == [self]
  end

  test "handle_call :engaged_connections only returns pending connections" do
    state = %{
      make_ref() => {:pending,  pid1=spawn_process, nil},
      make_ref() => {:finished, spawn_process, {:ok, "awesome"}},
      make_ref() => {:error,    spawn_process, %ArithmeticError{message: ""}},
      make_ref() => {:finished, spawn_process, {:ok, "hurray!"}},
      make_ref() => {:pending,  pid2=spawn_process, nil},
      make_ref() => {:pending,  pid3=spawn_process, nil},
    }
    {_, reply, _} = @module.handle_call(:engaged_connections, state)

    assert reply == [pid1, pid2, pid3]
  end

  test "handle_call :engaged_connections doesn't de-dup the pids" do
    pid1=spawn_process
    pid2=spawn_process
    state = %{
      make_ref() => {:pending,  pid1, nil},
      make_ref() => {:finished, pid2, {:ok, "awesome"}},
      make_ref() => {:error,    pid1, %ArithmeticError{message: ""}},
      make_ref() => {:finished, pid2, {:ok, "hurray!"}},
      make_ref() => {:pending,  pid1, nil},
      make_ref() => {:pending,  pid1, nil},
    }
    {_, reply, _} = @module.handle_call(:engaged_connections, state)

    assert reply == [pid1, pid1, pid1]
  end

  test "handle_call :engaged_connections handles no pending connections" do
    state = %{
      make_ref() => {:finished,  spawn_process, 200},
      make_ref() => {:finished, spawn_process, {:ok, "awesome"}},
      make_ref() => {:error,    spawn_process, %ArithmeticError{message: ""}},
      make_ref() => {:finished, spawn_process, {:ok, "hurray!"}},
      make_ref() => {:error,    spawn_process, %ArithmeticError{message: ""}},
    }
    {_, reply, _} = @module.handle_call(:engaged_connections, state)

    assert reply == []
  end

  test "handle_call :engaged_connections handles an empty state" do
    {_, reply, _} = @module.handle_call(:engaged_connections, %{})

    assert reply == []
  end
end
