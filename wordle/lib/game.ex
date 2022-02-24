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
            current_guess: "",
            keyboard: nil

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

  def add_letter(
        %Game{current_guess: current_guess, secret_word: secret_word, turn_state: :continue} =
          game,
        letter
      ) do
    updated_guess =
      if String.length(current_guess) == String.length(secret_word),
        do: game.current_guess,
        else: game.current_guess <> String.at(letter, 0)

    %Game{game | current_guess: updated_guess}
  end

  def add_letter(game, _) do
    game
  end

  def remove_letter(game = %Game{current_guess: current_guess, turn_state: :continue}) do
    updated_guess =
      if current_guess == "",
        do: "",
        else: String.replace_suffix(current_guess, String.at(current_guess, -1), "")

    %Game{game | current_guess: updated_guess}
  end

  def remove_letter(game) do
    game
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
  def make_guess(game, guess) do
    make_guess(%Game{game | current_guess: guess})
  end

  def make_guess(game = %Game{turn_state: :continue}) do
    if String.length(game.current_guess) == String.length(game.secret_word) do
      {guess_result, _remainders} = Guess.guess(game.current_guess, game.secret_word)
      updated_game = filter_remainders(game, guess_result)

      %Game{updated_game | current_guess: "", guesses: [guess_result | game.guesses]}
      |> turn_result()
    else
      game
    end
  end

  def make_guess(game) do
    %Game{game | current_guess: ""}
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

  # Keyboard colour function:
  def key_status(game) do
    # Get all guesses from game state
    # Compile into a flattened list of key/value pairs and remove duplicates
    guesses = List.flatten(game.guesses)
    # Retrieve a list of keyboard letters all set with the :initial key
    keyboard = Enum.map(Enum.to_list(?a..?z), fn n -> <<n>> end)

    keyboard =
      for letter <- keyboard do
        {:initial, letter}
      end

    # Remove partials when they have a correct version with same letter
    guesses = Enum.reduce(guesses, [], fn {status, letter}, acc ->
      if Enum.member?(guesses, {:partial, letter}) && Enum.member?(guesses, {:correct, letter}) do
        [{:correct, letter} | acc]
      else
        [{status, letter} | acc]
      end
    end)

    # Set all correct letter keys to :correct in keyboard colours
    keyboard = Enum.reduce(keyboard, [], fn {status, letter}, acc ->
      cond do
        Enum.member?(guesses, {:correct, letter}) ->
          [{:correct, letter} | acc]
        Enum.member?(guesses, {:partial, letter}) ->
          [{:partial, letter} | acc]
        Enum.member?(guesses, {:incorrect, letter}) ->
          [{:incorrect, letter} | acc]
        true -> [{status, letter} | acc]
      end
      |> Enum.reverse()
    end)
    %Game{game | keyboard: keyboard}
  end




  # Set all partial letter keys to :partial in keyboard colours
  # Set all incorrect letter keys to :incorrect in keyboard colours
end
