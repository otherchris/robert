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
    motion_stack: [],
    needs_second: false
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
  @spec motion_to_adjourn(Action.data()) :: Floor.t()
  def motion_to_adjourn({floor, _, _}) do
    floor
    |> Map.put(:motion_stack, floor.motion_stack ++ [:motion_to_adjourn])
    |> Map.put(:needs_second, true)
  end

  @doc """
  Seconds the motion on the floor
  """
  @spec second(Actions.data()) :: Floor.t()
  def second({floor, _, _}), do: Map.put(floor, :needs_second, false)

end
