defmodule Actions do
  @moduledoc """
  Defines the behavior of our system by listing the actions. That is, `Floor` and `Rules` both need to implement
  every action.
  """

  @doc """
  The action type specification is

  - Current floor state
  - Subject
  - Object

  This is enough to allow us to determine if the action is permitted and what the resulting floor state will be.
  """
  @type t() :: {Floor.t(), String.t(), String.t() | atom}
  @type result() :: :ok | {:error, atom} | Floor.t()

  @callback motion_to_adjourn(t()) :: result()
  @callback recognize(t()) :: result()

end
