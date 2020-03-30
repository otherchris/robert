defmodule RulesServerTest do
  @moduledoc false

  use ExUnit.Case
  doctest RulesServer

  setup do
    rules_server = start_supervised!(RulesServer)
    %{rules_server: rules_server}
  end

  describe "apply_action" do
    # Testing on the "motion_to_adjourn" action. Individual actions and their
    # effects should be tested on Floor and Rules. This case is enough to
    # verify the behavior of the RulesServer.
    test "make a motion to adjourn if allowed", %{rules_server: rules_server} do
      RulesServer.apply_action(rules_server, {:motion_to_adjourn, "member_id_has_floor", ""})
      %{floor: %{motion_stack: ms}} = :sys.get_state(rules_server)
      assert ms == [:motion_to_adjourn]
    end

    test "do not make a motion to adjourn if not allowed", %{rules_server: rules_server} do
      RulesServer.apply_action(rules_server, {:motion_to_adjourn, "member_id", ""})
      %{floor: %{motion_stack: ms}} = :sys.get_state(rules_server)
      assert ms == []
    end
  end
end
