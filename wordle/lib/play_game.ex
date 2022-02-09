defmodule PlayGame do

  def start_game() do
    game = Game.new(Enum.random(Dictionary.secret_dictionary()))
    take_turn(game)
  end


    @doc """
    Asks the player for their guess and takes their input via the keyboard. Then, it calls the guess method on the player's input and make's the guess to the list of guesses stored in the current game's state.
  """
  def get_player_guess(game) do
    guess = String.trim(IO.gets("Enter your guess:\n"))
    guess_valid?(game, guess)
  end

  def guess_valid?(game, guess) do
    cond do
      String.length(guess) > String.length(game.secret_word) ->
        IO.puts("Your guess was too long - try a different word\n")
        get_player_guess(game)
      String.length(guess) < String.length(game.secret_word) ->
        IO.puts("Your guess was too short - try a different word\n")
        get_player_guess(game)
      true ->
        if Enum.member?(game.guess_dictionary, guess) do
          guess
        else
          IO.puts("Please enter a valid word")
          get_player_guess(game)
        end
    end
  end

  def take_turn(game) do
    guess = get_player_guess(game)
    game = Game.make_guess(game, guess)
    cond do
      game.turn_state == :continue ->
        get_last_guess(game)
        take_turn(game)
      game.turn_state == :win -> "You win! The answer was #{game.secret_word}"
      true -> "Game over! The answer was #{game.secret_word}. Better luck next time!"
    end
  end

  def get_last_guess(game) do
    if !Enum.empty?(game.guesses) do
      [last_guess| _tail] = game.guesses
      IO.puts("Nice try - here's your guess result\n")
      IO.inspect(last_guess)
    end
  end

end
