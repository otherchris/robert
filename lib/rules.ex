defmodule Rules do
  @moduledoc """
  Rules definitions

  {:ok, member_id, floor} go ahead
  {:error, msg} stop, fall through
  """

  @behaviour Actions

  @doc """
  Make a motion to adjourn. Allowed if member has the floor.

  ## Examples:

      iex> floor = %Floor{ speaker: "member_id" }
      ...> Rules.motion_to_adjourn({floor, "member_id", ""})
      :ok

      iex> floor = %Floor{ speaker: "member_id" }
      ...> Rules.motion_to_adjourn({floor, "other_member_id", ""})
      {:error, :has_floor}
  """
  @spec motion_to_adjourn(Action.t()) :: :ok | {:error, atom}
  def motion_to_adjourn({floor = %Floor{}, member_id, _}) when is_binary(member_id) do
    with {:ok, _}  <- Checks.has_floor({:ok, {floor, member_id, :any}})
    do
      :ok
    else
      e -> e
    end
  end

  @doc """
  Recognize a speaker. Allowed for chair only.

  ## Examples:
      iex> floor = %Floor{ chair: "member_id" }
      ...> Rules.recognize({floor, "member_id", ""})
      :ok

      iex> floor = %Floor{ speaker: "member_id" }
      ...> Rules.recognize({floor, "other_member_id", ""})
      {:error, :is_chair}
  """
  @spec recognize(Action.t()) :: :ok | {:error, atom}
  def recognize({floor = %Floor{}, subject_id, object_id}) when is_binary(subject_id) and is_binary(object_id) do
    with {:ok, _} <- Checks.is_chair({:ok, {floor, subject_id, object_id}})
    do
      :ok
    else
      e -> e
    end
  end
end
