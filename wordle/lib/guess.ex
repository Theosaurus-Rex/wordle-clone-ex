defmodule Guess do
  @type guess_result :: :correct | :incorrect | :partial
  @type letter_guess_result :: {guess_result, binary}
  @type word_guess_result :: list(letter_guess_result)

  @spec guess_word(binary, binary) :: word_guess_result

  def guess_word(player_guess, secret_word) do
    secret_word_charlist = String.to_charlist(secret_word)

    {result, _} =
      player_guess
      |> String.to_charlist()
      |> Enum.zip(secret_word_charlist)
      |> Enum.reduce({[], secret_word_charlist}, fn {guess_letter, secret_letter},
                                                    {result, secret_letters} ->
        letter_result = check_matches({guess_letter, secret_letter}, secret_letters)
        {[letter_result | result], secret_letters -- [guess_letter]}
      end)

    Enum.reverse(result)
  end

  def check_matches({guess_letter, secret_letter}, secret_word) do
    cond do
      guess_letter == secret_letter -> {:correct, to_string([guess_letter])}
      guess_letter in secret_word -> {:partial, to_string([guess_letter])}
      true -> {:incorrect, to_string([guess_letter])}
    end
  end
end
