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

  def handle_call({:allow_motion, member_id, _}, _from, state) do
    if state.floor.speaker == member_id do
      {:reply, true, state}
    else
      {:reply, false, state}
    end
  end

  def handle_cast({:make_motion, member_id, :adjourn}, state = %{floor: floor}) do
    new_state =
      if GenServer.call(self(), {:allow_motion, member_id, :adjourn}) do
        new_floor = Floor.move(floor, :adjourn);
        Map.put(state, :floor, new_floor)
      else
        state
      end
    {:noreply, new_state}
  end

end
