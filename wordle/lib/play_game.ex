

defmodule PlayGame do
  def start_game() do
    game = Game.new()
    game = Game.set_secret(game, Enum.random(game.dictionary))
    take_turn(game)
  end

  def take_turn(game) do
    turn_result = Game.get_player_guess(game)
    # cond do
    #   turn_result == :continue -> take_turn()
    # end
    # 1 used all turns
    # 2 won game
    # 3 keep going calls taketurn again
    # get the user input

    # input is compared to secret word

    # result goes to games guesses
  end
end
