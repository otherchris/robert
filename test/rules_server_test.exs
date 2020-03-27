defmodule RulesServerTest do
  @modeuldoc false

  use ExUnit.Case
  doctest RulesServer

  setup do
    rules_server = start_supervised!(RulesServer)
    GenServer.cast(rules_server, {:set_floor, %Floor{speaker: "member_id_has_floor"}})
    %{rules_server: rules_server}
  end

  describe "allowing actions" do
    test "motion to adjourn not allowed if member does not have the floor", %{rules_server: rules_server} do
      refute GenServer.call(rules_server, {:allow_motion, "member_id", :adjourn})
    end

    test "motion to adjourn allowed if member does have the floor", %{rules_server: rules_server} do
      assert GenServer.call(rules_server, {:allow_motion, "member_id_has_floor", :adjourn})
    end
  end

  describe "commands" do
    test "make a motion to adjourn if allowed", %{rules_server: rules_server} do
      GenServer.cast(rules_server, {:make_motion, "member_id_has_floor", :adjourn})
      %{floor: %{motion_stack: ms}} = :sys.get_state(rules_server)
      assert ms == [:adjourn]
    end

    test "do not make a motion to adjourn if not allowed", %{rules_server: rules_server} do
      GenServer.cast(rules_server, {:make_motion, "member_id", :adjourn})
      %{floor: %{motion_stack: ms}} = :sys.get_state(rules_server)
      assert ms == []
    end
  end
end
