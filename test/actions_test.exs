defmodule ActionsTest do
  @moduledoc false

  use ExUnit.Case
  doctest Actions

  describe "recognize" do
    test "subject must be the chair" do
      assert {:error, :is_chair} = Actions.check_action({:recognize, {%Meeting{}, "some_subject", "some_object"}})
    end

    test "recognize sets the speaker" do
      {:ok, meeting} = Actions.apply_action({:recognize, {%Meeting{chair: "chair"}, "chair", "some_object"}})
      assert meeting.speaker == "some_object"
    end
  end

  describe "motion_to_adjourn" do
    test "subject must be the speaker" do
      assert {:error, :has_floor} = Actions.check_action({:motion_to_adjourn, {%Meeting{}, "some_subject", :any}})
    end

    test "motion_to_adjourn pushes the motion onto the motion stack" do
      {:ok, meeting} = Actions.apply_action({:motion_to_adjourn, {%Meeting{speaker: "speaker"}, "speaker", :any}})
      assert meeting.motion_stack == [:motion_to_adjourn]
    end

    test "motion to adjourn needs a second" do
      {:ok, meeting} = Actions.apply_action({:motion_to_adjourn, {%Meeting{speaker: "speaker"}, "speaker", :any}})
      assert meeting.waiting_for_second
    end
  end

  describe "second" do
    test "must need a second" do
      assert {:error, :waiting_for_second} = Actions.check_action({:second, {%Meeting{}, "some_subject", :any}})
    end

    test "unsets need_second?" do
      {:ok, meeting} = Actions.apply_action({:second, {%Meeting{waiting_for_second: true}, "speaker", :any}})
      refute meeting.waiting_for_second
    end
  end

  describe "call_vote" do
    test "subject must be the chair" do
      assert {:error, :is_chair} = Actions.check_action({:call_vote, {%Meeting{}, "some_subject", :any}})
    end

    test "must not be waiting for second" do
      assert {:error, :not_waiting_for_second} = Actions.check_action({:call_vote, {%Meeting{chair: "chair", waiting_for_second: true}, "chair", :any}})
    end

    test "must not be voting" do
      assert {:error, :not_voting} = Actions.check_action({:call_vote, {%Meeting{chair: "chair", voting: true}, "chair", :any}})
    end

    test "sets voting" do
      {:ok, meeting} = Actions.apply_action({:call_vote, {%Meeting{chair: "chair"}, "chair", :any}})
      assert meeting.voting
    end

    test "sets vote" do
      {:ok, meeting} = Actions.apply_action({:call_vote, {%Meeting{chair: "chair", vote: %{}}, "chair", :any}})
      assert meeting.vote == %{ yeas: [], nays: [] }
    end
  end

  describe "vote" do
    test "must be voting" do
      assert {:error, :voting} = Actions.check_action({:vote, {%Meeting{voting: false, vote: %{yeas: [], nays: []}}, "subject_id", :yea}})
    end

    test "object must be a vote" do
      assert {:error, :object_is_vote} = Actions.check_action({:vote, {%Meeting{voting: true}, "subject_id", :not_a_vote}})
    end

    test "registers new vote" do
      {:ok, %{vote: %{yeas: yeas, nays: nays}}} = Actions.apply_action({:vote, {%Meeting{voting: true, vote: %{yeas: [], nays: []}}, "subject_id", :yea}})
      assert yeas == ["subject_id"]
      assert nays == []

      {:ok, %{vote: %{yeas: yeas, nays: nays}}} = Actions.apply_action({:vote, {%Meeting{voting: true, vote: %{yeas: [], nays: []}}, "subject_id", :nay}})
      assert yeas == []
      assert nays == ["subject_id"]
    end

    test "changes existing vote" do
      {:ok, %{vote: %{yeas: yeas, nays: nays}}} = Actions.apply_action({:vote, {%Meeting{voting: true, vote: %{yeas: [], nays: ["subject_id"]}}, "subject_id", :yea}})
      assert yeas == ["subject_id"]
      assert nays == []

      {:ok, %{vote: %{yeas: yeas, nays: nays}}} = Actions.apply_action({:vote, {%Meeting{voting: true, vote: %{yeas: ["subject_id"], nays: []}}, "subject_id", :nay}})
      assert yeas == []
      assert nays == ["subject_id"]
    end
  end

  describe "end_vote" do
    test "subject must be the chair" do
      assert {:error, :is_chair} = Actions.check_action({:end_vote, {%Meeting{voting: true}, "some_subject", :any}})
    end

    test "must be voting" do
      assert {:error, :voting} = Actions.check_action({:end_vote, {%Meeting{chair: "subject_id", voting: false}, "subject_id", :yea}})
    end

    test "unsets voting" do
      {:ok, meeting} = Actions.apply_action({:end_vote, {%Meeting{ chair: "subject_id", voting: true }, "subject_id", :any}})
      refute meeting.voting
    end

    test "copies vote to last_vote" do
      {:ok, meeting} = Actions.apply_action({:end_vote, {%Meeting{ chair: "subject_id", voting: true, vote: :some_value}, "subject_id", :any}})
      assert meeting.last_vote == :some_value
    end

    test "unsets vote" do
      {:ok, meeting} = Actions.apply_action({:end_vote, {%Meeting{ chair: "subject_id", voting: true, vote: :some_value}, "subject_id", :any}})
      assert meeting.vote == %{}
    end
  end
end
