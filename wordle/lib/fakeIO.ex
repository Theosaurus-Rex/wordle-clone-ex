defmodule FakeIO do
  @moduledoc """
  Fakes out user input for testing the CLI.
  """
  defdelegate puts(message), to: IO

  def gets("Enter your guess:\n"), do: "shops"
end
