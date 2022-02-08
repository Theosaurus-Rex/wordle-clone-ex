import Game

defmodule PlayGame do
  def start_game() do
    game = Game.new()
    game = Game.set_secret(game)
    guess = Game.get_player_guess(game)
    cond do
      guess == "Keep playing" -> Game.get_player_guess(game)
      true -> "GAME OVER!"
    end
  end

  def take_turn(game) do
    # 1 used all turns
    # 2 won game
    # 3 keep going calls taketurn again
    # get the user input

    # input is compared to secret word

    # result goes to games guesses
  end
end
