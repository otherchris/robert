defmodule Checks do
  @moduledoc """
  Check for certain conditions in the conjunction of a `Floor` and a member id.

  {:ok, member_id, floor} go ahead
  {:error, msg} stop, fall through
  """

  @type check_pass() :: {:ok, Actions.data()}
  @type check_fail() :: {:error, atom}

  @doc """
  Check to see if the given subject currently has the floor

  ## Examples:

      iex> floor = %Floor{ speaker: "member_id" }
      ...> Checks.has_floor({:ok, {floor, "member_id", :any}})
      {:ok, {%Floor{ speaker: "member_id" }, "member_id", :any}}

      iex> floor = %Floor{ speaker: "member_id" }
      ...> Checks.has_floor({:ok, {floor, "other_member_id", :any}})
      {:error, :has_floor}

      iex> Checks.has_floor({:error, :previous_error})
      {:error, :previous_error}
  """
  @spec has_floor(check_pass() | check_fail()) :: check_pass() | check_fail()
  def has_floor({:ok, {floor = %Floor{speaker: speaker}, subject_id, object_id}}) do
    if subject_id == speaker do
      {:ok, {floor, subject_id, object_id}}
    else
      {:error, :has_floor}
    end
  end
  def has_floor({:error, msg}), do: {:error, msg}

  @doc """
  Check to see if the given subject is the chair

  ## Examples:

      iex> floor = %Floor{ chair: "member_id" }
      ...> Checks.is_chair({:ok, {floor, "member_id", :any}})
      {:ok, {%Floor{ chair: "member_id"}, "member_id", :any }}

      iex> floor = %Floor{ chair: "member_id" }
      ...> Checks.is_chair({:ok, {floor, "other_member_id", :any}})
      {:error, :is_chair}

      iex> Checks.is_chair({:error, :previous_error})
      {:error, :previous_error}
  """
  @spec is_chair(check_pass() | check_fail()) :: check_pass() | check_fail()
  def is_chair({:ok, {floor = %Floor{chair: chair}, subject_id, object_id}}) do
    if subject_id == chair do
      {:ok, {floor, subject_id, object_id}}
    else
      {:error, :is_chair}
    end
  end
  def is_chair({:error, msg}), do: {:error, msg}

  def needs_second?({:ok, data = {floor, subject_id, object_id}}) do
    if floor.needs_second do
      {:ok, data}
    else
      {:error, :needs_second?}
    end
  end
  def needs_second?({:error, msg}), do: {:error, msg}
end
