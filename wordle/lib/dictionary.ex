defmodule Dictionary do
  @spec validate_guess(any) :: boolean
  def validate_guess(guess) do
    dictionary = guess_dictionary() ++ secret_dictionary()
    Enum.member?(dictionary, guess)
  end

  def get_secret do
    secret_dictionary() |> Enum.random()
  end

  defp secret_dictionary do
    File.read!('lib/dictionary/wordle-answers-alphabetical.txt')
    |> String.split("\n", trim: true)
  end

  defp guess_dictionary do
    File.read!('lib/dictionary/wordle-allowed-guesses.txt')
    |> String.split("\n", trim: true)
  end
end
