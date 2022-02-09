defmodule PlayGameTest do
  use ExUnit.Case
  test "player's first guess is incorrect" do
    game = Game.new("mouse")
    turn_result = PlayGame.get_player_guess(game)
    turn_result = Game.make_guess(game, turn_result)
    assert turn_result.turn_state == :continue
  end
end
