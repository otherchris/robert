defmodule Floor do
  @moduledoc """
  The `Floor` is abstraction of the "state" of the meeting. Whether a certain action
  can proceed is a question of who is doing it (and to whom), together with the current
  meeting state represented by a `Floor`.

  The functions in this module map Action data (a tuple of `Floor`, member id
  of the subject, member_id of the object) to the resulting `Floor`.
  """

  defstruct [
    :chair,
    :speaker,
    :vote,
    motion_stack: [],
    waiting_for_second: false,
    voting: false
  ]

  @type t() :: %Floor{}

  @doc """
  Chair recognizes a speaker
  """
  @spec recognize(Actions.data()) :: Floor.t()
  def recognize({floor, _, new_speaker}), do: Map.put(floor, :speaker, new_speaker)

  @doc """
  Make a motion to adjourn
  """
  @spec motion_to_adjourn(Actions.data()) :: Floor.t()
  def motion_to_adjourn({floor, _, _}) do
    floor
    |> Map.put(:motion_stack, floor.motion_stack ++ [:motion_to_adjourn])
    |> Map.put(:waiting_for_second, true)
  end

  @doc """
  Seconds the motion on the floor
  """
  @spec second(Actions.data()) :: Floor.t()
  def second({floor, _, _}), do: Map.put(floor, :waiting_for_second, false)

  @doc """
  Calls a vote
  """
  @spec call_vote(Actions.data()) :: Floor.t()
  def call_vote({floor, _, _}) do
    floor
    |> Map.put(:vote, %{yeas: [], nays: []})
    |> Map.put(:voting, true)
  end

  @doc """
  Applies a vote
  """
  @spec vote(Actions.data()) :: Floor.t()
  def vote({floor = %{vote: %{yeas: yeas, nays: nays}}, subject, choice}) do
    [yeas, nays] = Enum.map([yeas, nays], &Enum.reject(&1, fn(x) -> x == subject end))
    [yeas, nays] =
      case choice do
        :yea -> [yeas ++ [subject], nays]
        :nay -> [yeas, nays ++ [subject]]
      end
    Map.put(floor, :vote, %{yeas: yeas, nays: nays})
  end
end
