defmodule Guess do
  use TypeCheck

  @moduledoc """
    Provides methods for parsing and operating on guesses entered by the player.
  """
  @type! guess_result :: :correct | :incorrect | :partial
  @type! letter_guess_result :: {guess_result(), binary}
  @type! word_guess_result :: list(letter_guess_result())

  @doc """
    Takes the player's guess and the secret word, and compares each of their characters by pairing them up.
    Returns a list of tuples stating the guess status (correct, incorrect, partial) paired with the letter that status represents.
  """

  @spec! guess(String.t(), String.t()) :: {list(letter_guess_result()), list}
  def guess(player_guess, secret_word) do
    player_guess
    |> correct_pass(secret_word)
    |> partial_pass(player_guess)
  end

  @spec! initial_state(charlist()) :: list({:incorrect, char()})
  def initial_state(secret_letters) do
    secret_letters
    |> Enum.map(fn letter -> {:incorrect, letter} end)
  end

  @spec! correct_pass(String.t(), String.t()) :: {list(letter_guess_result()), list}
  def correct_pass(player_guess, secret_letters) do
    secret_letter_charlist = String.to_charlist(secret_letters)

    {result, remainders} =
      player_guess
      |> String.to_charlist()
      |> Enum.zip(initial_state(secret_letter_charlist))
      |> Enum.reduce({[], secret_letter_charlist}, fn {guess_letter, {_status, secret_letter}},
                                                      {result, remaining_letters} ->
        compare_letter(guess_letter, secret_letter, result, remaining_letters)
      end)

    {Enum.reverse(result), remainders}
  end

  @spec! compare_letter(char, char, list, list) :: {list, list}
  def compare_letter(letter, letter, result, remaining_letters) do
    {[{:correct, to_string([letter])} | result], remaining_letters -- [letter]}
  end

  def compare_letter(guess_letter, _, result, remaining_letters) do
    {[{:incorrect, to_string([guess_letter])} | result], remaining_letters}
  end

  @spec! partial_pass({word_guess_result(), charlist()}, String.t()) :: {list(letter_guess_result()), charlist()}
  def partial_pass({letter_state, remainders}, player_guess) do
    {result, remainders} =
      player_guess
      |> String.to_charlist()
      |> Enum.zip(letter_state)
      |> Enum.reduce({[], remainders}, fn {guess_letter, {status, _secret_letter}},
                                          {result, remaining_letters} ->
        partial_match(guess_letter, status, remaining_letters, result)
      end)

    {Enum.reverse(result), remainders}
  end

  @spec partial_match(any, any, any, any) :: {nonempty_maybe_improper_list, any}
  defp partial_match(guess_letter, :correct, remainders, result) do
    {[{:correct, to_string([guess_letter])} | result], remainders}
  end

  defp partial_match(guess_letter, _, remainders, result) do
    cond do
      Enum.member?(remainders, guess_letter) ->
        {[{:partial, to_string([guess_letter])} | result], remainders -- [guess_letter]}

      true ->
        {[{:incorrect, to_string([guess_letter])} | result], remainders}
    end
  end
end
