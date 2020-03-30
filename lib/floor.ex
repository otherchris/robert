defmodule Floor do
  @moduledoc """
  Documentation for `Floor`.
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
  @impl true
  def recognize({floor, _, new_speaker}), do: Map.put(floor, :speaker, new_speaker)

  @doc """
  Make a motion to adjourn
  """
  @spec motion_to_adjourn(Action.t()) :: Floor.t()
  @impl true
  def motion_to_adjourn({floor, _, _}) do
    floor
    |> Map.put(:motion_stack, floor.motion_stack ++ [:motion_to_adjourn])
    |> Map.put(:needs_second, true)
  end

  @doc """
  Seconds the motion on the floor
  """
  @spec second(Actions.t()) :: Floor.t()
  @impl true
  def second({floor, _, _}), do: Map.put(floor, :needs_second, false)

end
