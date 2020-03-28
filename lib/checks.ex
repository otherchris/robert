defmodule Checks do
  @moduledoc """
  Check for certain conditions in the conjunction of a `Floor` and a member id.

  {:ok, member_id, floor} go ahead
  {:error, msg} stop, fall through
  """

  @type check_pass() :: {:ok, Floor.t(), String.t()}
  @type check_fail() :: {:error, atom}

  @doc """
  Check to see if the given member currently has the floor

  ## Examples:

      iex> floor = %Floor{ speaker: "member_id" }
      ...> Checks.has_floor({:ok, floor, "member_id"})
      {:ok, %Floor{ speaker: "member_id" }, "member_id"}

      iex> floor = %Floor{ speaker: "member_id" }
      ...> Checks.has_floor({:ok, floor, "other_member_id"})
      {:error, :check_floor}

      iex> Checks.has_floor({:error, :previous_error})
      {:error, :previous_error}
  """
  @spec has_floor(check_pass() | check_fail()) :: check_pass() | check_fail()
  def has_floor({:ok, floor = %Floor{speaker: speaker}, member_id}) do
    if member_id == speaker do
      {:ok, floor, member_id}
    else
      {:error, :check_floor}
    end
  end
  def has_floor({:error, msg}), do: {:error, msg}
end
