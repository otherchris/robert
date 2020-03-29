defmodule Rules do
  @moduledoc """
  Rules definitions

  {:ok, member_id, floor} go ahead
  {:error, msg} stop, fall through
  """

  @behaviour Actions

  @doc """
  Make a motion to adjourn. Allowed if member has the floor

  ## Examples:

      iex> floor = %Floor{ speaker: "member_id" }
      ...> Rules.motion_to_adjourn(floor, "member_id")
      :ok

      iex> floor = %Floor{ speaker: "member_id" }
      ...> Rules.motion_to_adjourn(floor, "other_member_id")
      {:error, :check_floor}
  """
  @spec motion_to_adjourn(Floor.t(), String.t()) :: :ok | {:error, atom}
  def motion_to_adjourn(floor = %Floor{}, member_id) when is_binary(member_id) do
    with {:ok, _, _} <- Checks.has_floor({:ok, floor, member_id})
    do
      :ok
    else
      e -> e
    end
  end
end
