defmodule Actions do
  @moduledoc """
  Defines the behavior of our system by listing the actions. That is, `Floor` and `Rules` both need to implement
  every action.
  """

  @callback motion_to_adjourn(Floor.t(), String.t()) :: :ok | {:error, atom} | Floor.t()

end
