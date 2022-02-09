

defmodule PlayGame do
  def start_game() do
    game = Game.new()
    game = Game.set_secret(game, Enum.random(game.dictionary))
    take_turn(game)
  end

  def take_turn(game) do
    turn_result = Game.get_player_guess() |> Game.make_guess(game)
    if !Enum.empty?(turn_result.guesses) do
      [last_guess| _tail] = Enum.reverse(turn_result.guesses)
      last_guess = for x <- Keyword.keys(last_guess), do: "#{x}: #{Keyword.get(last_guess, x)}  "
      IO.puts("Here's what you guessed last turn:\n#{last_guess}")
    end
    cond do
      turn_result.turn_state == :continue -> take_turn(turn_result)
      turn_result.turn_state == :win -> "You win! The answer was #{turn_result.secret_word}"
      true -> "Game over! The answer was #{turn_result.secret_word}. Better luck next time!"
    end
  end
end
