defmodule Rules do
  @moduledoc """
  Rules definitions

  {:ok, member_id, floor} go ahead
  {:error, msg} stop, fall through
  """

  @type rule_success() :: {:ok, String.t(), Floor.t()}
  @type rule_failure() :: {:error, String.t()}


  @doc """
  Does the member have the floor?
  """
  @spec has_floor(rule_success{} | rule_failure()) :: rule_success() || rule_failure()
  def has_floor({:ok, member_id, floor = %Floor{speaker: speaker}}) do
    if member_id == speaker do
      {:ok, member_id, floor}
    else
      {:error, "Member does not have the floor"}
    end
  end
end
