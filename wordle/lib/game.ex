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
  end

end