defmodule Dictionary do
  @spec secret_dictionary :: [binary]
  def secret_dictionary do
    File.read!('lib/dictionary/wordle-answers-alphabetical.txt')
    |> String.split("\n", trim: true)
  end

  @spec guess_dictionary :: [binary]
  def guess_dictionary do
    File.read!('lib/dictionary/wordle-allowed-guesses.txt')
    |> String.split("\n", trim: true)
  end

  @spec validate_secret(any) :: boolean
  def validate_secret(secret_word) do
    secret_dictionary()
    |> Enum.member?(secret_word)
  end

  @spec validate_guess(any) :: boolean
  def validate_guess(guess) do
    guess_dictionary()
    |> Enum.member?(guess)
  end
end
