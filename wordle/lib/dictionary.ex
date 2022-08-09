defmodule Dictionary do
  @moduledoc """
    This module handles all funcionality to do with the database of words that the game can use.
  """
  @spec validate_guess(any) :: boolean
  def validate_guess(guess) do
    dictionary = guess_dictionary() ++ secret_dictionary()
    Enum.member?(dictionary, guess)
  end

  def get_secret do
    secret_dictionary() |> Enum.random()
  end

  defp secret_dictionary do
    Application.app_dir(:wordle, "priv/dictionary/wordle-answers-alphabetical.txt")
    |> File.read!()
    |> String.split("\n", trim: true)
  end

  defp guess_dictionary do
    Application.app_dir(:wordle, "priv/dictionary/wordle-allowed-guesses.txt")
    |> File.read!()
    |> String.split("\n", trim: true)
  end
end
