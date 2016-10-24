defmodule NetSuite.Connections.ResponseHandlerTest do
  use ExUnit.Case, async: true

  @module NetSuite.Connections.ResponseHandler

  setup do
    ref = make_ref()
    {:ok, %{ref: ref}}
  end

  test "handle_event :request_begin adds to current state", %{ref: ref} do
    {:ok, new_state} = @module.handle_event({:request_begin, ref}, %{})

    assert new_state == %{ref => {:pending, nil}}
  end

  test "handle_event :request_end writes over current state", %{ref: ref} do
    state = %{ref => {:pending, nil}}
    {:ok, new_state} = @module.handle_event({:request_end, {ref, 42}}, state)

    assert new_state == %{ref => {:finished, 42}}
  end

  test "handle_event :request_error writes over current state", %{ref: ref} do
    state = %{ref => {:pending, nil}}
    {:ok, new_state} = @module.handle_event({:request_error, {ref, :blah}}, state)

    assert new_state == %{ref => {:error, :blah}}
  end

  test "handle_call :get handles missing ticket", %{ref: ref} do
    state = %{fake: :response}
    {:ok, reply, new_state} = @module.handle_call({:get, ref}, state)

    assert reply == {:error, "response not found for reference", ref}
    assert new_state == state
  end

  test "handle_call :get does not delete pending requests", %{ref: ref} do
    state = %{ref => {:pending, nil}}
    {:ok, reply, new_state} = @module.handle_call({:get, ref}, state)

    assert reply == {:pending, nil}
    assert new_state == state
  end

  test "handle_call :get deletes finished requests", %{ref: ref} do
    state = %{ref => {:finished, 42}}
    {:ok, reply, new_state} = @module.handle_call({:get, ref}, state)

    assert reply == {:ok, 42}
    assert new_state == %{}
  end

  test "handle_call :get deletes failed requests", %{ref: ref} do
    state = %{ref => {:error, %ArithmeticError{message: 42}}}
    {:ok, reply, new_state} = @module.handle_call({:get, ref}, state)

    assert reply == {:error, %ArithmeticError{message: 42}}
    assert new_state == %{}
  end
end
