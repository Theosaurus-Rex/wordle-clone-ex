defmodule CLI do
  def start_game() do
    game = Game.new(Dictionary.get_secret())
    get_player_guess(game)
  end

  @doc """
    Asks the player for their guess and takes their input via the keyboard. Then, it calls the guess method on the player's input and make's the guess to the list of guesses stored in the current game's state.
  """
  def get_player_guess(game) do
    guess = String.trim(IO.gets("Enter your guess:\n"))
    {status, error_message} = Game.guess_valid?(game, guess)

    case {status, error_message} do
      {:error, error_message} ->
        print_error(error_message)
        get_player_guess(game)

      _ ->
        take_turn(game, guess)
    end
  end

  def take_turn(game, guess) do
    game = Game.make_guess(game, guess)

    cond do
      game.turn_state == :win ->
        declare_win(game)

      game.turn_state == :lose ->
        declare_game_over(game)

      true ->
        output_last_guess(hd(game.guesses))
        get_player_guess(game)
    end
  end

  def print_error(:guess_too_long) do
    IO.puts("Your guess was too long - try a different word\n")
  end

  def print_error(:guess_too_short) do
    IO.puts("Your guess was too short - try a different word\n")
  end

  def print_error(:invalid_guess) do
    IO.puts("Please enter a valid word")
  end

  def declare_win(game) do
    IO.puts("You win! The answer was #{game.secret_word}")
  end

  def declare_game_over(game) do
    "Game over! The answer was #{game.secret_word}. Better luck next time!"
  end

  def output_last_guess(last_guess) do
    IO.puts("Nice try - here's your guess result\n")

    IO.inspect(
      Enum.map(last_guess, fn {r, _} ->
        case r do
          :correct -> "🟩"
          :partial -> "🟨"
          _ -> "⬜"
        end
      end)
    )

    guess_output =
      Enum.map(last_guess, fn {_, letter} ->
        letter
      end)

    IO.inspect(Enum.join(guess_output))
  end
end
