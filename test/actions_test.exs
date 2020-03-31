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

    test "must not be voting" do
      assert {:error, :not_voting} = Actions.check_action({:call_vote, {%Floor{chair: "chair", voting: true}, "chair", :any}})
    end

    test "sets voting" do
      {:ok, floor} = Actions.apply_action({:call_vote, {%Floor{chair: "chair"}, "chair", :any}})
      assert floor.voting
    end

    test "sets vote" do
      {:ok, floor} = Actions.apply_action({:call_vote, {%Floor{chair: "chair", vote: %{}}, "chair", :any}})
      assert floor.vote == %{ yeas: [], nays: [] }
    end
  end

  describe "vote" do
    test "must be voting" do
      assert {:error, :voting} = Actions.check_action({:vote, {%Floor{voting: false, vote: %{yeas: [], nays: []}}, "subject_id", :yea}})
    end

    test "object must be a vote" do
      assert {:error, :object_is_vote} = Actions.check_action({:vote, {%Floor{voting: true}, "subject_id", :not_a_vote}})
    end

    test "registers new vote" do
      {:ok, %{vote: %{yeas: yeas, nays: nays}}} = Actions.apply_action({:vote, {%Floor{voting: true, vote: %{yeas: [], nays: []}}, "subject_id", :yea}})
      assert yeas == ["subject_id"]
      assert nays == []

      {:ok, %{vote: %{yeas: yeas, nays: nays}}} = Actions.apply_action({:vote, {%Floor{voting: true, vote: %{yeas: [], nays: []}}, "subject_id", :nay}})
      assert yeas == []
      assert nays == ["subject_id"]
    end

    test "changes existing vote" do
      {:ok, %{vote: %{yeas: yeas, nays: nays}}} = Actions.apply_action({:vote, {%Floor{voting: true, vote: %{yeas: [], nays: ["subject_id"]}}, "subject_id", :yea}})
      assert yeas == ["subject_id"]
      assert nays == []

      {:ok, %{vote: %{yeas: yeas, nays: nays}}} = Actions.apply_action({:vote, {%Floor{voting: true, vote: %{yeas: ["subject_id"], nays: []}}, "subject_id", :nay}})
      assert yeas == []
      assert nays == ["subject_id"]
    end
  end

  describe "end_vote" do
    test "subject must be the chair" do
      assert {:error, :is_chair} = Actions.check_action({:end_vote, {%Floor{voting: true}, "some_subject", :any}})
    end

    test "must be voting" do
      assert {:error, :voting} = Actions.check_action({:end_vote, {%Floor{chair: "subject_id", voting: false}, "subject_id", :yea}})
    end

    test "unsets voting" do
      {:ok, floor} = Actions.apply_action({:end_vote, {%Floor{ chair: "subject_id", voting: true }, "subject_id", :any}})
      refute floor.voting
    end

    test "copies vote to last_vote" do
      {:ok, floor} = Actions.apply_action({:end_vote, {%Floor{ chair: "subject_id", voting: true, vote: :some_value}, "subject_id", :any}})
      assert floor.last_vote == :some_value
    end

    test "unsets vote" do
      {:ok, floor} = Actions.apply_action({:end_vote, {%Floor{ chair: "subject_id", voting: true, vote: :some_value}, "subject_id", :any}})
      assert floor.vote == %{}
    end
  end
end
