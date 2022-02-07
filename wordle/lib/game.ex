import Guess

defmodule Game do
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

  def new, do: %Game{}

  def set_secret(%Game{dictionary: dictionary} = game) do
    %Game{game | secret_word: Enum.random(dictionary)}
  end

  def add_guess(%Game{guesses: guesses} = game, player_guess) do
    %Game{game | guesses: guesses ++ [player_guess]}
  end

end
