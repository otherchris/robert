defmodule RulesServer do
  @moduledoc """
  Applies to rules set and allows/disallows actions
  """

  use GenServer

  # Client API

  @doc """
  Start the rules server
  """
  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @doc """
  Return the list of allowed actions for a given subject.
  """
  @spec allowed_actions(pid, String.t()) :: [{atom, boolean}]
  def allowed_actions(server, subject_id) do
    GenServer.call(server, {:action_list, subject_id})
  end

  @doc """
  Apply an action
  """
  @spec apply_action(pid, Action.t()) :: :ok
  def apply_action(server, {action, subject_id, object_id}) do
    GenServer.cast(server, {:action, action, subject_id, object_id})
    :ok
  end

  # Server callbacks

  @impl true
  def init(:ok) do
    {:ok, %{
      floor: %Floor{},
      chair: "",
      members: []
    }}
  end

  @impl true
  def handle_call(:report, _from, state) do
    {:reply, state, state}
  end

  # TODO: add introspection into Actions to get a comprehensive list
  @impl true
  def handle_call({:action_list, subject_id}, _from, state = %{floor: floor}) do
    list =
      [:motion_to_adjourn]
      |> Enum.map(fn(action) -> {action, apply(Rules, action, [{floor, subject_id, :any}])} end)
    {:reply, list, state}
  end

  @impl true
  def handle_cast({:set_floor, f = %Floor{}}, state) do
    {:noreply, Map.put(state, :floor, f)}
  end

  # TODO: add introspection into Actions to ensure the message is a real action
  @impl true
  def handle_cast({:action, action, subject_id, object_id}, state = %{floor: floor}) do
    new_state =
      with :ok <- apply(Rules, action, [{floor, subject_id, object_id}]) do
        new_floor = apply(Floor, action, [{floor, subject_id, object_id}])
        Map.put(state, :floor, new_floor)
      else
        _ -> state
      end
    {:noreply, new_state}
  end
end
