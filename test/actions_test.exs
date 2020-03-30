defmodule ActionsTest do
  @moduledoc false

  use ExUnit.Case
  doctest Actions

  describe "recognize" do
    test "subject must be the chair" do
      assert {:error, :is_chair} = Actions.check_action({:recognize, {%Floor{}, "some_subject", "some_object"}})
    end

    test "recognize sets the speaker" do
      floor = Actions.apply_action({:recognize, {%Floor{chair: "chair"}, "chair", "some_object"}})
      assert floor.speaker == "some_object"
    end
  end

  describe "motion_to_adjourn" do
    test "subject must be the speaker" do
      assert {:error, :has_floor} = Actions.check_action({:motion_to_adjourn, {%Floor{}, "some_subject", :any}})
    end

    test "motion_to_adjourn pushes the motion onto the motion stack" do
      floor = Actions.apply_action({:motion_to_adjourn, {%Floor{speaker: "speaker"}, "speaker", :any}})
      assert floor.motion_stack == [:motion_to_adjourn]
    end

    test "motion to adjourn needs a second" do
      floor = Actions.apply_action({:motion_to_adjourn, {%Floor{speaker: "speaker"}, "speaker", :any}})
      assert floor.needs_second
    end
  end

  describe "second" do
    test "must need a second" do
      assert {:error, :needs_second?} = Actions.check_action({:second, {%Floor{}, "some_subject", :any}})
    end

    test "unsets need_second?" do
      floor = Actions.apply_action({:second, {%Floor{needs_second: true}, "speaker", :any}})
      refute floor.needs_second
    end
  end
end
