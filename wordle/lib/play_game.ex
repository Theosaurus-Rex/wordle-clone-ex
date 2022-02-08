import Guess
import Game

defmodule PlayGame do
  def play_game() do
    game = Game.new()
    game = Game.set_secret(game)
    Guess.get_player_guess(game, game.secret_word)
  end
end
