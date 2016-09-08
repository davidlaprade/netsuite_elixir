defmodule NetSuite.HTTP do

  @moduledoc """
    The interface used by the app's HTTP library
  """

  @callback get(uri :: String.t, headers :: Map.t) :: Tuple.t

end
