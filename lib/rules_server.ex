defmodule RulesServer do
  @moduledoc """
  Models a given meeting
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
  Get the current meeting state
  """
  @spec get_meeting(pid()) :: Meeting.t()
  def get_meeting(server) do
    GenServer.call(server, :report)
  end

  @doc """
  Recognize a speaker
  """
  @spec recognize(pid(), String.t(), String.t()) :: :ok
  def recognize(server, new_speaker, actor_id) do
    GenServer.cast(server, {:recognize, new_speaker, actor_id})
  end

  @doc """
  Make a motion
  """
  @spec motion(pid(), String.t, String.t) :: :ok
  def motion(server, motion_content, actor_id) do
    GenServer.cast(server, {:motion, motion_content, actor_id})
  end

  # Server callbacks

  @impl true
  def init(:ok) do
    {:ok, %Meeting{
        chair: "chair",
        speaker: "member_id_has_floor", # for testing TODO: clean up
        motion_stack: []
      }
    }
  end

  @impl true
  def handle_call(:report, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_cast({:recognize, new_speaker, actor_id}, state = %{chair: chair}) do
    if actor_id == chair do
      {:noreply, Meeting.recognize(state, new_speaker)}
    else
      {:noreply, state}
    end
  end

  @impl true
  def handle_cast({:motion, motion_content, actor_id}, state) do
    {:noreply, Meeting.motion(state, %{content: motion_content, actor_id: actor_id})}
  end
end
