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
    :question,
    question_stack: [],

    waiting_for_second: false,
    voting: false
  ]

  @type vote() :: %{member_id: String.t(), vote: String.t()}
  @type vote_result() :: %{question: question(), votes: list(vote())}
  @type question() :: %{content: String.t(), type: Atom.t(), subject: String.t(), object: any()}

  @type t() :: %Meeting{
    chair: String.t(),
    speaker: String.t(),
    current_vote: list(vote()),
    all_votes: list(vote_result()),
    question: question(),
    question_stack: list(question()),

    waiting_for_second: boolean,
    voting: boolean
  }

  @doc """
  Speaker is recognized
  """
  @spec recognize(Actions.data()) :: Meeting.t()
  def recognize({meeting, _, new_speaker}), do: Map.put(meeting, :speaker, new_speaker)

  @doc """
  Make a motion 
  """
  @spec motion(Meeting.t(), question()) :: Meeting.t()
  def motion({meeting, motion}) do
    meeting
    |> Map.put(:question_stack, [question] ++ meeting.question_stack)
    |> Map.put(:waiting_for_second, true
    )
  end

  @doc """
  Seconds the motion on the floor 
  """
  @spec second(Meeting.t()) :: Meeting.t()
  def second(meeting), do: Map.put(meeting, :waiting_for_second, false)

  @doc """
  Calls a vote
  """
  @spec call_vote(Actions.data()) :: Meeting.t()
  def call_vote({meeting, _, _}) do
    meeting
    |> Map.put(:current_vote, [])
    |> Map.put(:voting, true)
  end

  @doc """
  Applies a vote
  """
  @spec vote(Meeting.t(), String.t(), String.t()) :: Meeting.t()
  def vote(meeting, subject_id, vote) do
    new_vote =
      meeting.current_vote
      |> Enum.reject(fn(v) => v.member_id == subject_id end)
      |> Kernel.++(%{member_id: subject_id, vote: vote})
    Map.put(meeting, :current_vote, new_vote)
  end

  @doc """
  Concludes and saves a vote
  """
  @spec end_vote(Meeting.t()) :: Meeting.t()
  def end_vote(meeting = %{question_stack: [curr | rest], all_votes: all_votes, vote: vote}) do
    meeting
    |> Map.put(:all_votes, all_votes ++ [%{vote: vote, question: hd(meeting.question_stack))
    |> Map.put(:question_stack, rest)
    |> Map.put(:current_vote, [])
    |> Map.put(:voting, false)
  end
end
