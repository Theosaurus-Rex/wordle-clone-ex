defmodule PlayGameTest do
  use ExUnit.Case
  # test "player's first guess is incorrect" do
  #   game = Game.new("mouse")
  #   turn_result = PlayGame.get_player_guess()
  #   turn_result = Game.make_guess(game, turn_result)
  #   assert turn_result.turn_state == :continue
  # end

  test "player entered a valid word" do
    game = Game.new("mouse")
    assert PlayGame.guess_valid?(game, "mouse") == "mouse"
  end

  # test "player enters word that is too long" do
  #   game = Game.new("leaps")
  #   assert PlayGame.guess_valid?(game, "potato") == "Your guess was too long - try a different word\n"
  # end
end
