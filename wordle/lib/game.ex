alias Guess

defmodule Game do
  @moduledoc """
    The Game module handles the state of the Wordle game. This includes keeping track of the dictionary, the number of turns allowed, the turns previously taken by the player, and the secret word for any instance of the game.
  """

  defstruct max_turns: 6,
            secret_word: "",
            guesses: [],
            remaining_letters: Enum.map(Enum.to_list(?a..?z), fn n -> <<n>> end),
            turn_state: :continue,
            current_guess: ""

  @type guess_result :: :correct | :incorrect | :partial
  @type letter_guess_result :: {guess_result, binary}
  @type word_guess_result :: list(letter_guess_result)

  @type turn_result :: :win | :lose | :continue

  @type word :: binary
  @type guess :: binary
  @type wordle_game :: %{
          max_turns: non_neg_integer(),
          secret_word: word(),
          guesses: list(word_guess_result())
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
  @spec new(any) :: %Game{}

  def new(secret_word \\ Dictionary.get_secret()) do
    game = %Game{}
    set_secret(game, secret_word)
  end

  def add_letter(game, letter) do
    %Game{game | current_guess: game.current_guess <> letter}
  end

  def remove_letter(game = %Game{current_guess: current_guess}) do
    updated_guess =
      if current_guess == "",
        do: "",
        else: String.trim_trailing(current_guess, String.at(current_guess, -1))

    %Game{game | current_guess: updated_guess}
  end

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
  @spec set_secret(%Game{}, binary) :: %Game{}
  def set_secret(game, secret) do
    %Game{game | secret_word: secret}
  end

  @spec guess_valid?(atom | %{:secret_word => binary, optional(any) => any}, binary) ::
          {:error, :guess_too_long | :guess_too_short | :invalid_guess} | {:ok, binary}
  def guess_valid?(game, guess) do
    cond do
      String.length(guess) > String.length(game.secret_word) ->
        {:error, :guess_too_long}

      String.length(guess) < String.length(game.secret_word) ->
        {:error, :guess_too_short}

      true ->
        if Dictionary.validate_guess(guess) do
          {:ok, guess}
        else
          {:error, :invalid_guess}
        end
    end
  end

  @spec make_guess(%Game{}, binary) :: %Game{}
  def make_guess(game, player_guess) do
    {guess_result, _remainders} = Guess.guess(player_guess, game.secret_word)
    updated_game = filter_remainders(game, guess_result)

    %Game{updated_game | current_guess: "", guesses: [guess_result | game.guesses]}
    |> turn_result()
  end

  @doc """
    When a player guess is passed in, the make_guess function appends that guess to the list of guesses stored in the game state.

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
      iex> make_guess(new_game, player_guess)
      %Game{
        dictionary: ["words", "games", "phone", "mouse"],
        guesses: [[incorrect: "d", correct: "o", incorrect: "g"]],
        max_turns: 6,
        secret_word: ""
      }
  """
  @spec turn_result(%Game{}) :: %Game{}

  def turn_result(%Game{guesses: _guesses} = game) do
    cond do
      correct_guess(game) -> %Game{game | turn_state: :win}
      check_loss(game) -> %Game{game | turn_state: :lose}
      true -> %Game{game | turn_state: :continue}
    end
  end

  @spec correct_guess(atom | %{:guesses => nonempty_maybe_improper_list, optional(any) => any}) ::
          boolean
  def correct_guess(game) do
    [last_guess | _tail] = game.guesses
    Enum.all?(last_guess, fn {result, _letter} -> result == :correct end)
  end

  @spec check_loss(atom | %{:guesses => list, :max_turns => any, optional(any) => any}) :: boolean
  def check_loss(game) do
    length(game.guesses) == game.max_turns
  end

  def filter_remainders(game, guess_letters) do
    updated_remainders =
      Enum.reduce(guess_letters, game.remaining_letters, fn {status, letter}, acc ->
        case status do
          :incorrect ->
            if Enum.member?(guess_letters, {:correct, letter}) ||
                 Enum.member?(guess_letters, {:correct, letter}) do
              acc
            else
              acc -- [letter]
            end

          _ ->
            acc
        end
      end)

    %Game{game | remaining_letters: updated_remainders}
  end
end
