defmodule Actions do
  @moduledoc """
  An action is a tuple with the action name and action data (`Meeting`, member_id of subject,
  member_id of object).

  This module does three things:

  - `list_of_actions/0` is the source of truth for what actions exist in the system and
  which `Checks` must be applied
  - `check_action/1` will determine if a given action is applicable given the state of
  the meeting and the members involved
  - `apply_action/1` will return the resulting state of the meeting after applying the
  action (or an error)
  """

  @type t() :: {atom, data()}
  @type data() :: {Meeting.t(), String.t(), String.t() | atom}
  @type result() :: {:ok, Meeting.t()} | {:error, atom}

  def list_of_actions, do: %{
    recognize: [:is_chair],
    motion_to_adjourn: [:has_floor],
    second: [:waiting_for_second],
    call_vote: [:is_chair, :not_waiting_for_second, :not_voting],
    vote: [:voting, :vote_set, :object_is_vote],
    end_vote: [:voting, :is_chair]
  }

  @spec check_action(t()) :: :ok | {:error, atom}
  def check_action({action_name, data}) do
    check =
      list_of_actions()
      |> Map.get(action_name)
      |> List.foldr({:ok, data}, fn(check, acc) -> apply(Checks, check, [acc]) end)
    case check do
      {:ok, _} -> :ok
      e -> e
    end
  end

  @spec apply_action(t()) :: result()
  def apply_action({action_name, data}) do
    with :ok <- check_action({action_name, data})
    do
      {:ok, apply(Meeting, action_name, [data])}
    else
      e -> e
    end
  end
end
