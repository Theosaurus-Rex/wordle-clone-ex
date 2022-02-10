alias Game

defmodule Guess do
  @moduledoc """
    Provides methods for parsing and operating on guesses entered by the player.
  """
  @type guess_result :: :correct | :incorrect | :partial
  @type letter_guess_result :: {guess_result, binary}
  @type word_guess_result :: list(letter_guess_result)

  @spec guess(binary, binary) :: word_guess_result

  @type word :: binary
  @type guess :: binary
  @type wordle_game :: %{
          dictionary: list(word()),
          max_turns: non_neg_integer(),
          secret_word: word(),
          guesses: list(word_guess_result())
        }
  @doc """
    Takes the player's guess and the secret word, and compares each of their characters by pairing them up.
    Returns a list of tuples stating the guess status (correct, incorrect, partial) paired with the letter that status represents.


    ## Examples

      iex> Guess.guess("rat", "car")
      [partial: "r", correct: "a", incorrect: "t"]
  """

  def guess(player_guess, secret_word) do
    secret_letters = String.to_charlist(secret_word)

    {result, _} =
      player_guess
      |> String.to_charlist()
      |> Enum.zip(secret_letters)
      |> Enum.reduce({[], secret_letters}, fn {guess_letter, secret_letter},
                                              {result, secret_letters} ->
        letter_result = check_letter(guess_letter, secret_letter, secret_letters)
        {[letter_result | result], secret_letters -- [guess_letter]}
      end)

    Enum.reverse(result)
  end

  @doc """
    Takes in a tuple containing 2 chars - one from the guess and one from the secret word, as well as the whole secret word.
    Compares the guess letter to the secret letter and returns its match status (correct, incorrect, partial) and the guess letter as a tuple.

    ## Examples

      iex> Guess.check_letter('d', 'c', 'cat')
      {:incorrect, "d"}

      iex> Guess.check_letter('o', 'o', 'frog')
      {:correct, "o"}
  """
  @spec check_letter(char, char, charlist) ::
          {:correct, binary} | {:incorrect, binary} | {:partial, binary}

  def check_letter(guess_letter, secret_letter, secret_letters) do
    cond do
      guess_letter == secret_letter -> {:correct, to_string([guess_letter])}
      guess_letter in secret_letters -> {:partial, to_string([guess_letter])}
      true -> {:incorrect, to_string([guess_letter])}
    end
  end

  def initial_state(secret_letters) do
    secret_letters
    |> Enum.map(fn letter -> {:incorrect, letter} end)
  end

  def correct_pass(player_guess, secret_letters) do
    secret_letter_charlist = String.to_charlist(secret_letters)

    {result, remainders} =
      player_guess
      |> String.to_charlist()
      |> Enum.zip(initial_state(secret_letter_charlist))
      |> Enum.reduce({[], secret_letter_charlist}, fn {guess_letter, {status, secret_letter}},
                                                      {result, remaining_letters} ->
                                                        compare_letter(guess_letter, secret_letter, result, remaining_letters)
      end)

    {Enum.reverse(result), remainders}
  end

  def compare_letter(letter, letter, result, remaining_letters) do
    {[{:correct, to_string([letter])} | result],
             remaining_letters -- [letter]}
  end

  def compare_letter(guess_letter, _, result, remaining_letters) do
    {[{:incorrect, to_string([guess_letter])} | result], remaining_letters}
  end

  def partial_pass(player_guess, updated_state, remainders) do
    {result, remainders} =
      player_guess
      |> String.to_charlist()
      |> Enum.zip(updated_state)
      |> Enum.reduce({[], remainders}, fn {guess_letter, {status, secret_letter}},
          {result, remaining_letters} ->
          partial_match(player_guess, status, remaining_letters, result)
    end)
  end

  def partial_match(player_guess, :correct, remainders, result) do
    {[{:correct, to_string([player_guess])} | result],
             remainders}
  end

  def partial_match(player_guess, _, remainders, result) do
    cond do
      Enum.member?(remainders, player_guess) ->
        {[{:partial, to_string([player_guess])} | result],
             remainders -- [player_guess]}
      true ->
        {[{:incorrect, to_string([player_guess])} | result],
              remainders}
    end
  end
end
