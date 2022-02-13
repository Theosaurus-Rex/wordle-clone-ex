defmodule CLITest do
  use ExUnit.Case

  test "returns ok status when a player guess is valid" do
    game = Game.new("couch")
    assert CLI.validate_guess(game, "couch") == {:ok, "couch"}
  end

  test "submit_guess ouputs win message when turn_state is :win" do
    game = Game.new("couch")
    assert CLI.submit_guess
  end
end
