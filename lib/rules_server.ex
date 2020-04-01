defmodule RulesServer do
  @moduledoc """
  Models a given meeting
  """

  use GenServer

  @type action_message() :: {atom, String.t(), String.t() | atom}

  # Client API

  @doc """
  Start the rules server
  """
  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @doc """
  Apply an action
  """
  @spec apply_action(pid, action_message()) :: :ok
  def apply_action(server, {action, subject_id, object_id}) do
    GenServer.cast(server, {:action, {action, subject_id, object_id}})
    :ok
  end

  @doc """
  Return the list of allowed actions
  """
  @spec check_actions(pid, String.t()) :: map
  def check_actions(server, subject_id) do
    server
    |> GenServer.call({:check_actions, subject_id})
    |> Enum.map(&(
      case &1 do
        {a, :ok} -> {a, true}
        {a, {:error, _}} -> {a, false}
      end
    ))
  end

  # Server callbacks

  @impl true
  def init(:ok) do
    {:ok, %{
      floor: %Floor{
        chair: "chair",
        speaker: "member_id_has_floor", # for testing TODO: clean up
        motion_stack: []
      },
      members: [],
    }}
  end

  @impl true
  def handle_call({:check_actions, subject_id}, _from, state) when is_binary(subject_id) do
    list =
      Actions.list_of_actions
      |> Enum.map(fn({k, v}) -> {k, Actions.check_action({k, {state.floor, subject_id, :any}})} end)
    {:reply, list, state}
  end

  @impl true
  def handle_cast({:action, {action, subject_id, object_id}}, state = %{floor: floor}) do
    new_state =
      with {:ok, new_floor} <- Actions.apply_action({action, {floor, subject_id, object_id}})
      do
        Map.put(state, :floor, new_floor)
      else
        {:error, _} -> state
      end
    {:noreply, new_state}
  end
end
