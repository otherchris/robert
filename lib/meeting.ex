defmodule Meeting do
  @moduledoc """
  The `Meeting` is abstraction of the "state" of the meeting. Whether a certain action
  can proceed is a question of who is doing it (and to whom), together with the current
  meeting state represented by a `Meeting`.

  The functions in this module map Action data (a tuple of `Meeting`, member id
  of the subject, member_id of the object) to the resulting `Meeting`.
  """

  defstruct [
    :chair,
    :speaker,
    :vote,
    :last_vote,
    motion_stack: [],
    waiting_for_second: false,
    voting: false
  ]

  @type t() :: %Meeting{}

  @doc """
  Chair recognizes a speaker
  """
  @spec recognize(Actions.data()) :: Meeting.t()
  def recognize({meeting, _, new_speaker}), do: Map.put(meeting, :speaker, new_speaker)

  @doc """
  Make a motion to adjourn
  """
  @spec motion_to_adjourn(Actions.data()) :: Meeting.t()
  def motion_to_adjourn({meeting, _, _}) do
    meeting
    |> Map.put(:motion_stack, meeting.motion_stack ++ [:motion_to_adjourn])
    |> Map.put(:waiting_for_second, true)
  end

  @doc """
  Seconds the motion on the Meeting
  """
  @spec second(Actions.data()) :: Meeting.t()
  def second({meeting, _, _}), do: Map.put(meeting, :waiting_for_second, false)

  @doc """
  Calls a vote
  """
  @spec call_vote(Actions.data()) :: Meeting.t()
  def call_vote({meeting, _, _}) do
    meeting
    |> Map.put(:vote, %{yeas: [], nays: []})
    |> Map.put(:voting, true)
  end

  @doc """
  Applies a vote
  """
  @spec vote(Actions.data()) :: Meeting.t()
  def vote({meeting = %{vote: %{yeas: yeas, nays: nays}}, subject, choice}) do
    [yeas, nays] = Enum.map([yeas, nays], &Enum.reject(&1, fn(x) -> x == subject end))
    [yeas, nays] =
      case choice do
        :yea -> [yeas ++ [subject], nays]
        :nay -> [yeas, nays ++ [subject]]
      end
    Map.put(meeting, :vote, %{yeas: yeas, nays: nays})
  end

  @doc """
  Concludes and saves a vote
  """
  @spec end_vote(Actions.data()) :: Meeting.t()
  def end_vote({meeting = %{vote: vote}, _, _}) do
    meeting
    |> Map.put(:last_vote, vote)
    |> Map.put(:vote, %{})
    |> Map.put(:voting, false)
  end
end
