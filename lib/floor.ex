defmodule Floor do
  @moduledoc """
  Documentation for `Floor`.
  """

  defstruct [
    :speaker,
    motion_stack: [],
    need_second: false
  ]
  @type t() :: %Floor{}

  @doc """
  Yield the floor to a member, who becomes the speaker
  """
  @spec yield_to(Floor.t(), String.t()) :: Floor.t()
  def yield_to(floor, new_speaker), do: Map.put(floor, :speaker, new_speaker)

  @doc """
  Make a motion on the floor
  """
  @spec move(Floor.t(), atom) :: Floor.t()
  def move(floor, :adjourn) do
    floor
    |> Map.put(:motion_stack, floor.motion_stack ++ [:adjourn])
    |> Map.put(:need_second, true)
  end

  @doc """
  Seconds the motion on the floor
  """
  @spec second(Floor.t()) :: Floor.t()
  def second(floor), do: Map.put(floor, :need_second, false)

end
