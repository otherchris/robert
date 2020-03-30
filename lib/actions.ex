defmodule Actions do
  @moduledoc """
  Actions

  The action type specification is

  - Action name
  - Current floor state
  - Subject
  - Object

  This is enough to allow us to determine if the action is permitted and what the resulting floor state will be.
  """

  @type t() :: {atom, data()}
  @type data() :: {Floor.t(), String.t(), String.t() | atom}
  @type result() :: Floor.t() | {:error, atom}

  def list_of_actions(), do: %{
    recognize: [:is_chair],
    motion_to_adjourn: [:has_floor],
    second: [:needs_second?]
  }

  @spec check_action(t()) :: :ok | {:error, atom}
  def check_action({action_name, data}) do
    with {:ok, _} <-
      list_of_actions()
      |> Map.get(action_name)
      |> List.foldr({:ok, data}, fn(check, acc) -> apply(Checks, check, [acc]) end)
    do
      :ok
    else
      e -> e
    end
  end

  @spec apply_action(t()) :: result()
  def apply_action({action_name, data}) do
    with :ok <- check_action({action_name, data})
    do
      apply(Floor, action_name, [data])
    else
      e -> e
    end
  end
end
