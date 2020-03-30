defmodule RulesServerTest do
  @moduledoc false

  use ExUnit.Case
  doctest RulesServer

  setup do
    rules_server = start_supervised!(RulesServer)
    GenServer.cast(rules_server, {:set_floor, %Floor{speaker: "member_id_has_floor"}})
    %{rules_server: rules_server}
  end

  describe "allowed_actions" do
    test "disallowed actions get a false", %{rules_server: rules_server} do
      list = RulesServer.allowed_actions(rules_server, "member_id")
      refute Enum.member?(list, {:motion_to_adjourn, {:error, :check_floor}})
    end

    test "allowed actions get a true", %{rules_server: rules_server} do
      list = RulesServer.allowed_actions(rules_server, "member_id_has_floor")
      assert Enum.member?(list, {:motion_to_adjourn, :ok})
    end
  end

  describe "apply_action" do
    # Testing on the "motion_to_adjourn" action. Individual actions and their
    # effects should be tested on Floor and Rules. This case is enough to
    # verify the behavior of the RulesServer.
    test "make a motion to adjourn if allowed", %{rules_server: rules_server} do
      RulesServer.apply_action(rules_server, {:motion_to_adjourn, "member_id_has_floor", ""})
      %{floor: %{motion_stack: ms}} = :sys.get_state(rules_server)
      assert ms == [:adjourn]
    end

    test "do not make a motion to adjourn if not allowed", %{rules_server: rules_server} do
      RulesServer.apply_action(rules_server, {:motion_to_adjourn, "member_id", ""})
      %{floor: %{motion_stack: ms}} = :sys.get_state(rules_server)
      assert ms == []
    end
  end
end
