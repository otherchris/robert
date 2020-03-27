defmodule FloorTest do
  use ExUnit.Case
  doctest Floor

  @base_floor %Floor{
    speaker: "other_member_id",
    motion_stack: [:motion]
  }

  describe "yield_to" do
    test "yield_to" do
      new_floor = Floor.yield_to(@base_floor, "member_id")
      assert new_floor.speaker == "member_id"
    end
  end

  describe "move to adjourn" do
    test "move to adjourn" do
      new_floor = Floor.move(@base_floor, :adjourn)
      assert new_floor.motion_stack == [:motion, :adjourn]
      assert new_floor.need_second == true
    end
  end

  describe "second" do
    test "second the current motion" do
      new_floor =
        @base_floor
        |> Map.put(:need_second, true)
        |> Floor.second()
      assert new_floor.need_second == false
    end
  end
end
