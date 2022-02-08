alias Guess

defmodule Game do
  @moduledoc """
    The Game module handles the state of the Wordle game. This includes keeping track of the dictionary, the number of turns allowed, the turns previously taken by the player, and the secret word for any instance of the game.
  """
  @dictionary ["words", "games", "phone", "mouse"]

  defstruct dictionary: @dictionary,
            max_turns: 6,
            secret_word: "",
            guesses: []

  @type guess_result :: :correct | :incorrect | :partial
  @type letter_guess_result :: {guess_result, binary}
  @type word_guess_result :: list(letter_guess_result)

  @type turn_result :: :win | :lose | :continue

  @type word :: binary
  @type guess :: binary
  @type wordle_game :: %{
          dictionary: list(word()),
          max_turns: non_neg_integer(),
          secret_word: word(),
          guesses: list(word_guess_result()),
        }

  @doc """
    Returns a new instance of Game with the properties defined in the struct.

    ## Examples

      iex> Game.new
      %Game{
        dictionary: ["words", "games", "phone", "mouse"],
        guesses: [],
        max_turns: 6,
        secret_word: ""
      }
  """
  def new, do: %Game{}

  @doc """
    Returns a random word from the dictionary and sets it as the secret word for the current Game instance.

    ## Examples

      iex> new_game = Game.new
      %Game{
        dictionary: ["words", "games", "phone", "mouse"],
        guesses: [],
        max_turns: 6,
        secret_word: ""
      }
      iex> Game.set_secret(new_game)
      %Game{
        dictionary: ["words", "games", "phone", "mouse"],
        guesses: [],
        max_turns: 6,
        secret_word: "phone"
      }
  """
  def set_secret(%Game{dictionary: dictionary} = game) do
    %Game{game | secret_word: Enum.random(dictionary)}
  end

  @doc """
    Asks the player for their guess and takes their input via the keyboard. Then, it calls the guess method on the player's input and add's the guess to the list of guesses stored in the current game's state.
  """
  def get_player_guess(game) do
    player_guess = String.trim(IO.gets("Enter your guess:\n"))
    Game.add_guess(game, Guess.guess(player_guess, game.secret_word))
  end

  @doc """
    When a player guess is passed in, the add_guess function appends that guess to the list of guesses stored in the game state.

    ## Examples

      iex> new_game = Game.new
      %Game{
        dictionary: ["words", "games", "phone", "mouse"],
        guesses: [],
        max_turns: 6,
        secret_word: ""
      }
      iex> player_guess = guess("dog", "for")
      incorrect: "d", correct: "o", incorrect: "g"]
      iex> add_guess(new_game, player_guess)
      %Game{
        dictionary: ["words", "games", "phone", "mouse"],
        guesses: [[incorrect: "d", correct: "o", incorrect: "g"]],
        max_turns: 6,
        secret_word: ""
      }
  """
  def add_guess(%Game{guesses: guesses} = game, player_guess) do
    %Game{game | guesses: guesses ++ [player_guess]}
    |> win_game()
  end

  @doc """
    Takes a current game state as the argument and checks if the user has any turns remaining by comparing the number of guesses made so far to the number of maximum turns.
  """
  def game_over(%Game{guesses: _guesses, max_turns: _max_turns, secret_word: _secret_word} = game) do
    cond do
      length(game.guesses) < game.max_turns -> "Keep playing"
      length(game.guesses) == game.max_turns -> "GAME OVER!"
    end
  end

  @doc """
    Takes the most recent guess submitted by the player and assesses whether or not they have guessed the secret word, i.e. whether or not all of the keys in their guess response have returned as "correct".
    If any of the keys are equal or :incorrect or :partial, it runs the game_over function to check if the player has any turns remaining.
  """
  def win_game(%Game{guesses: _guesses} = game) do
    [head | _tail] = Enum.reverse(game.guesses)
    last_guess = head
    has_incorrect = Keyword.has_key?(last_guess, :incorrect)
    has_partial = Keyword.has_key?(last_guess, :partial)
    cond do
      has_incorrect || has_partial -> game_over(game)
      !has_incorrect && !has_partial -> "YOU WON!"
    end
  end
end
