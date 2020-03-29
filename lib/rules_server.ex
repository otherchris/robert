defmodule RulesServer do
  @moduledoc """
  Applies to rules set and allows/disallows actions
  """

  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    {:ok, %{
      floor: %Floor{},
      chair: "",
      members: []
    }}
  end

  def handle_cast({:set_floor, f = %Floor{}}, state) do
    {:noreply, Map.put(state, :floor, f)}
  end

  def handle_call(:report, _from, state) do
    {:reply, state, state}
  end

  # TODO: add introspection into Actions to get a comprehensive list
  def handle_call({:action_list, member_id}, _from, state = %{floor: floor}) do
    list =
      [:motion_to_adjourn]
      |> Enum.map(fn(action) -> {action, apply(Rules, action, [floor, member_id])} end)
    {:reply, list, state}
  end

  # TODO: add introspection into Actions to ensure the message is a real action
  def handle_cast({:action, action, member_id}, state = %{floor: floor}) do
    new_state =
      with :ok <- apply(Rules, action, [floor, member_id]) do
        new_floor = apply(Floor, action, [floor, member_id])
        Map.put(state, :floor, new_floor)
      else
        e -> state
      end
    {:noreply, new_state}
  end
end
