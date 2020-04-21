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
    :current_vote,
    :all_votes,
    motion_stack: [],

    waiting_for_second: false,
    voting: false
  ]

  @type vote() :: %{member_id: String.t(), vote: String.t()}
  @type vote_result() :: %{motion: motion(), votes: list(vote())}
  @type motion() :: %{content: String.t(), actor_id: String.t()}

  @type t() :: %Meeting{
    chair: String.t(),
    speaker: String.t(),
    current_vote: list(vote()),
    all_votes: list(vote_result()),
    motion_stack: list(motion()),

    waiting_for_second: boolean,
    voting: boolean
  }

  @doc """
  Speaker is recognized
  """
  @spec recognize(Meeting.t(), String.t()) :: Meeting.t()
  def recognize(meeting, new_speaker), do: Map.put(meeting, :speaker, new_speaker)

  @doc """
  Make a motion 
  """
  @spec motion(Meeting.t(), motion()) :: Meeting.t()
  def motion(meeting, motion) do
    meeting
    |> Map.put(:motion_stack, [motion] ++ meeting.motion_stack)
    |> Map.put(:waiting_for_second, true)
  end

  @doc """
  Calls a vote
  """
  @spec call_vote(Meeting.t()) :: Meeting.t()
  def call_vote(meeting) do
    meeting
    |> Map.put(:current_vote, [])
    |> Map.put(:voting, true)
  end

  @doc """
  Applies a vote
  """
  @spec vote(Meeting.t(), vote()) :: Meeting.t()
  def vote(meeting, vote) do
    new_vote =
      meeting.current_vote
      |> Enum.reject(fn(v) -> v.member_id == vote.member_id end)
      |> Kernel.++([vote])
    Map.put(meeting, :current_vote, new_vote)
  end

  @doc """
  Concludes and saves a vote
  """
  @spec end_vote(Meeting.t()) :: Meeting.t()
  def end_vote(meeting = %{question_stack: [curr | rest], all_votes: all_votes, vote: vote}) do
    meeting
    |> Map.put(:all_votes, all_votes ++ [%{vote: vote, question: hd(meeting.question_stack)}])
    |> Map.put(:question_stack, rest)
    |> Map.put(:current_vote, [])
    |> Map.put(:voting, false)
  end
end
