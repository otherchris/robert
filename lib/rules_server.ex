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

  # Server callbacks

  @impl true
  def init(:ok) do
    {:ok, %{
      floor: %Floor{
        chair: "",
        speaker: "member_id_has_floor", # for testing TODO: clean up
        motion_stack: []
      },
      members: [],
    }}
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
