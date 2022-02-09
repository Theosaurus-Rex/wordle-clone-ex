defmodule PlayGame do
  @dictionary ["words", "games", "phone", "mouse"]

  def start_game() do
    game = Game.new(Enum.random(@dictionary))
    take_turn(game)
  end

  def take_turn(game) do
    guess_result = get_player_guess()
    turn_result = Game.make_guess(game, guess_result)
    if !Enum.empty?(turn_result.guesses) do
      [last_guess| _tail] = turn_result.guesses
      IO.puts("Nice try - here's your guess result\n")
      IO.inspect(last_guess)
    end
    cond do
      turn_result.turn_state == :continue -> take_turn(turn_result)
      turn_result.turn_state == :win -> "You win! The answer was #{turn_result.secret_word}"
      true -> "Game over! The answer was #{turn_result.secret_word}. Better luck next time!"
    end
  end

    @doc """
    Asks the player for their guess and takes their input via the keyboard. Then, it calls the guess method on the player's input and make's the guess to the list of guesses stored in the current game's state.
  """
  def get_player_guess() do
    String.trim(IO.gets("Enter your guess:\n"))
  end

  def guess_valid?(game, guess) do
    if Enum.member?(game.dictionary, guess) do
      guess
    else
      IO.puts("Please enter a valid word")
      get_player_guess()
    end
  end
end
