defmodule ActionsTest do
  @moduledoc false

  use ExUnit.Case
  doctest Actions

  describe "recognize" do
    test "subject must be the chair" do
      assert {:error, :is_chair} = Actions.check_action({:recognize, {%Floor{}, "some_subject", "some_object"}})
    end

    test "recognize sets the speaker" do
      {:ok, floor} = Actions.apply_action({:recognize, {%Floor{chair: "chair"}, "chair", "some_object"}})
      assert floor.speaker == "some_object"
    end
  end

  describe "motion_to_adjourn" do
    test "subject must be the speaker" do
      assert {:error, :has_floor} = Actions.check_action({:motion_to_adjourn, {%Floor{}, "some_subject", :any}})
    end

    test "motion_to_adjourn pushes the motion onto the motion stack" do
      {:ok, floor} = Actions.apply_action({:motion_to_adjourn, {%Floor{speaker: "speaker"}, "speaker", :any}})
      assert floor.motion_stack == [:motion_to_adjourn]
    end

    test "motion to adjourn needs a second" do
      {:ok, floor} = Actions.apply_action({:motion_to_adjourn, {%Floor{speaker: "speaker"}, "speaker", :any}})
      assert floor.waiting_for_second
    end
  end

  describe "second" do
    test "must need a second" do
      assert {:error, :waiting_for_second} = Actions.check_action({:second, {%Floor{}, "some_subject", :any}})
    end

    test "unsets need_second?" do
      {:ok, floor} = Actions.apply_action({:second, {%Floor{waiting_for_second: true}, "speaker", :any}})
      refute floor.waiting_for_second
    end
  end

  describe "call_vote" do
    test "subject must be the chair" do
      assert {:error, :is_chair} = Actions.check_action({:call_vote, {%Floor{}, "some_subject", :any}})
    end

    test "must not be waiting for second" do
      assert {:error, :not_waiting_for_second} = Actions.check_action({:call_vote, {%Floor{chair: "chair", waiting_for_second: true}, "chair", :any}})
    end

    test "sets voting" do
      {:ok, floor} = Actions.apply_action({:call_vote, {%Floor{chair: "chair"}, "chair", :any}})
      assert floor.voting
    end
  end
end
