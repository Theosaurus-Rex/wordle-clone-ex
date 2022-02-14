defmodule FakeIO do
  defdelegate puts(message), to: IO

  def gets("Enter your guess:\n"), do: "shops"
end
