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

  def handle_call({:allow_motion, member_id, :adjourn}, _from, state = %{floor: floor}) do
    case Rules.motion_to_adjourn(floor, member_id) do
      :ok -> {:reply, true, state}
      _ -> {:reply, false, state}
    end
  end

  def handle_cast({:make_motion, member_id, :adjourn}, state = %{floor: floor}) do
    new_state =
      with :ok <- Rules.motion_to_adjourn(floor, member_id) do
        new_floor = Floor.motion_to_adjourn(floor, member_id)
        Map.put(state, :floor, new_floor)
      else
        e -> state
      end
    {:noreply, new_state}
  end

  defp apply_event(floor_transform, rule_function, state, member_id) do
    case apply(Rules, rule_function, [member_id, state.floor]) do
      {:ok, _, _} ->
        new_floor = apply(Floor, floor_transform, [state.floor])
        Map.put(state, :floor, new_floor)
      _ -> state
    end
  end
end
