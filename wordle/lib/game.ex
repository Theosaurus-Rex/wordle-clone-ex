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

  def game_over(%Game{guesses: guesses, max_turns: max_turns, secret_word: secret_word} = game) do
    cond do
      length(game.guesses) < game.max_turns -> "Keep playing"
      length(game.guesses) == game.max_turns -> "GAME OVER!"
    end
  end

  def win_game(%Game{guesses: guesses} = game) do
    [head | tail] = Enum.reverse(game.guesses)
    last_guess = head
    has_incorrect = Keyword.has_key?(last_guess, :incorrect)
    has_partial = Keyword.has_key?(last_guess, :partial)
    cond do
      has_incorrect || has_partial -> game_over(game)
      !has_incorrect && !has_partial -> "YOU WON!"
    end
  end

  # C player initiates new game
  # C the game sets a secret word (set_secret)
  # C player inputs first guess (guess)
  #     C game checks if player guess is correct (check_letter)
  #         if the guess has incorrect or partial letter, the game contues and player needs to make a new guess
  #             the player gets new turn (add_guess)
  #         if the guess has only correct letters, the player wins (win_game)
  #         if the player doenst guess correctly after 6 turns the game is over (game_over)

end
