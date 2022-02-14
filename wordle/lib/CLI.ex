defmodule CLI do
  def start_game(secret_word \\ Dictionary.get_secret()) do
    secret_word
    |> Game.new()
    |> turn()
  end

  def turn(game) do
    {_status, guess} = get_player_guess(game)
    submit_guess(game, guess)
  end

  def get_player_guess(game) do
    guess = get_player_input()
    validate_guess(game, guess)
  end
  @doc """
    Asks the player for their guess and takes their input via the keyboard. Then, it calls the guess method on the player's input and make's the guess to the list of guesses stored in the current game's state.
  """
  def get_player_input(io \\ IO) do
   String.trim(io.gets("Enter your guess:\n"))
  end

  def validate_guess(game, guess) do
    {status, error_message} = Game.guess_valid?(game, guess)

    case {status, error_message} do
      {:error, error_message} ->
        print_error(error_message)
        get_player_guess(game)

      _ ->
        {:ok, guess}
    end
  end

  def submit_guess(game, guess) do
    game = Game.make_guess(game, guess)

    cond do
      game.turn_state == :win ->
        declare_win(game)

      game.turn_state == :lose ->
        declare_game_over(game)

      true ->
        output_last_guess(game, hd(game.guesses))
        turn(game)
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
    "You win! The answer was #{game.secret_word}"
  end

  def declare_game_over(game) do
    "Game over! The answer was #{game.secret_word}. Better luck next time!"
  end

  def output_last_guess(game, last_guess) do
    IO.puts("Nice try - here's your guess result\n")

    IO.puts(
      Enum.map(last_guess, fn {r, _} ->
        case r do
          :correct -> "🟩"
          :partial -> "🟨"
          _ -> "⬜"
        end
      end)
      |> Enum.join()
    )

    guess_output =
      Enum.map(last_guess, fn {_, letter} ->
        letter
      end)

    IO.puts(Enum.join(guess_output))

    IO.puts("Here are the letters not yet eliminated:\n")
    IO.puts(game.remaining_letters)
  end
end
