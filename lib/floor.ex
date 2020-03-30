defmodule Floor do
  @moduledoc """
  Documentation for `Floor`.
  """

  @behaviour Actions

  defstruct [
    :chair,
    :speaker,
    motion_stack: [],
    need_second: false
  ]
  @type t() :: %Floor{}

  @doc """
  Chair recognizes a speaker
  """
  @spec recognize(Action.t()) :: Floor.t()
  @impl true
  def recognize({floor, _, new_speaker}), do: Map.put(floor, :speaker, new_speaker)

  @doc """
  Make a motion to adjourn
  """
  @spec motion_to_adjourn(Action.t()) :: Floor.t()
  @impl true
  def motion_to_adjourn({floor, _, _}) do
    floor
    |> Map.put(:motion_stack, floor.motion_stack ++ [:adjourn])
    |> Map.put(:need_second, true)
  end

  @doc """
  Seconds the motion on the floor
  """
  @spec second(Floor.t()) :: Floor.t()
  @impl true
  def second(floor), do: Map.put(floor, :need_second, false)

end
