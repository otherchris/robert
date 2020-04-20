defmodule Checks do
  @moduledoc """
  Check for certain conditions in a given tuple of Action data (`Meeting`, member_id of
  subject, member_id of object).

  {:ok, (action tuple)} go ahead with next check

  {:error, msg} stop, fall through
  """

  @type check_pass() :: {:ok, Actions.data()}
  @type check_fail() :: {:error, atom}

  @doc """
  Check to see if the given subject currently has the Meeting

  ## Examples:

      iex> meeting = %Meeting{ speaker: "member_id" }
      ...> Checks.has_floor({:ok, {meeting, "member_id", :any}})
      {:ok, {%Meeting{ speaker: "member_id" }, "member_id", :any}}

      iex> meeting = %Meeting{ speaker: "member_id" }
      ...> Checks.has_floor({:ok, {meeting, "other_member_id", :any}})
      {:error, :has_floor}

      iex> Checks.has_floor({:error, :previous_error})
      {:error, :previous_error}
  """
  @spec has_floor(check_pass() | check_fail()) :: check_pass() | check_fail()
  def has_floor({:ok, {meeting = %Meeting{speaker: speaker}, subject_id, object_id}}) do
    if subject_id == speaker do
      {:ok, {meeting, subject_id, object_id}}
    else
      {:error, :has_floor}
    end
  end
  def has_floor({:error, msg}), do: {:error, msg}

  @doc """
  Check to see if the given subject is the chair

  ## Examples:

      iex> meeting = %Meeting{ chair: "member_id" }
      ...> Checks.is_chair({:ok, {meeting, "member_id", :any}})
      {:ok, {%Meeting{ chair: "member_id"}, "member_id", :any }}

      iex> meeting = %Meeting{ chair: "member_id" }
      ...> Checks.is_chair({:ok, {meeting, "other_member_id", :any}})
      {:error, :is_chair}

      iex> Checks.is_chair({:error, :previous_error})
      {:error, :previous_error}
  """
  @spec is_chair(check_pass() | check_fail()) :: check_pass() | check_fail()
  def is_chair({:ok, data = {%Meeting{chair: chair}, subject_id, _}}) do
    if subject_id == chair do
      {:ok, data}
    else
      {:error, :is_chair}
    end
  end
  def is_chair({:error, msg}), do: {:error, msg}

  @spec waiting_for_second(check_pass() | check_fail()) :: check_pass() | check_fail()
  def waiting_for_second({:ok, data = {meeting, _, _}}) do
    if meeting.waiting_for_second do
      {:ok, data}
    else
      {:error, :waiting_for_second}
    end
  end
  def waiting_for_second({:error, msg}), do: {:error, msg}

  @spec not_waiting_for_second(check_pass() | check_fail()) :: check_pass() | check_fail()
  def not_waiting_for_second({:ok, data = {meeting, _, _}}) do
    if !meeting.waiting_for_second do
      {:ok, data}
    else
      {:error, :not_waiting_for_second}
    else
      {:ok, data}
    end
  end
  def not_waiting_for_second({:error, msg}), do: {:error, msg}

  @spec not_voting(check_pass() | check_fail()) :: check_pass() | check_fail()
  def not_voting({:ok, data = {meeting, _, _}}) do
    if !meeting.voting do
      {:ok, data}
    else
      {:error, :not_voting}
    else
      {:ok, data}
    end
  end
  def not_voting({:error, msg}), do: {:error, msg}

  @spec object_is_vote(check_pass() | check_fail()) :: check_pass() | check_fail()
  def object_is_vote({:ok, data = {_, _, object}}) do
    case object do
      :yea -> {:ok, data}
      :nay -> {:ok, data}
      _ -> {:error, :object_is_vote}
    end
  end
  def object_is_vote({:error, msg}), do: {:error, msg}

  @spec voting(check_pass() | check_fail()) :: check_pass() | check_fail()
  def voting({:ok, data = {meeting, _, _}}) do
    if meeting.voting do
      {:ok, data}
    else
      {:error, :voting}
    end
  end
  def voting({:error, msg}), do: {:error, msg}

  @spec vote_set(check_pass() | check_fail()) :: check_pass() | check_fail()
  def vote_set({:ok, data = {meeting, _, _}}) do
    case meeting.vote do
      %{yeas: _, nays: _} -> {:ok, data}
      _ -> {:error, :vote_set}
    end
  end
  def vote_set({:error, msg}), do: {:error, msg}
end
