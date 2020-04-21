defmodule RulesServerTest do
  @moduledoc false

  use ExUnit.Case
  doctest RulesServer

  setup do
    rules_server = start_supervised!(RulesServer)
    %{rules_server: rules_server}
  end

  describe "get_meeting" do
    test "reports the state of the meeting", %{rules_server: rs} do
      %{chair: chair} = RulesServer.get_meeting(rs)
      assert chair == "chair"
    end
  end

  describe "recognize" do
    test "recognize updates speaker if the chair does it", %{rules_server: rs} do
      RulesServer.recognize(rs, "new_speaker_id", "chair")
      %{speaker: speaker} = :sys.get_state(rs)
      assert speaker == "new_speaker_id"
    end

    test "recognize does not update the speaker if it's not the chair doing it", %{rules_server: rs} do
      RulesServer.recognize(rs, "new_speaker_id", "not chair")
      %{speaker: speaker} = :sys.get_state(rs)
      assert speaker != "new_speaker_id"
    end
  end

  describe "motion" do
    test "motion adds a motion to the motion stack", %{rules_server: rs} do
      RulesServer.motion(rs, "move to boogie", "not chair")
      %{motion_stack: [last_motion | _rest]} = :sys.get_state(rs)
      assert last_motion.content == "move to boogie"
    end
  end
end
