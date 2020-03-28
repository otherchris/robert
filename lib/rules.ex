defmodule Rules do
  @moduledoc """
  Rules definitions

  {:ok, member_id, floor} go ahead
  {:error, msg} stop, fall through
  """

  @type rule_success() :: {:ok, String.t(), Floor.t()}
  @type rule_failure() :: {:error, String.t()}

  @doc """
  Make a motion to adjourn
  """
  @spec motion_to_adjourn(String.t(), Floor.t()) :: rule_success() | rule_failure()
  def motion_to_adjourn(member_id, floor) do
    {:ok, member_id, floor}
    |> has_floor()
  end

  # Does the member have the floor?
  @spec has_floor(rule_success() | rule_failure()) :: rule_success() | rule_failure()
  defp has_floor({:ok, member_id, floor = %Floor{speaker: speaker}}) do
    if member_id == speaker do
      {:ok, member_id, floor}
    else
      {:error, "Member does not have the floor"}
    end
  end

end
