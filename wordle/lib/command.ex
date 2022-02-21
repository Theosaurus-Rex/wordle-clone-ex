defmodule Wordle.Command do
  @doc """
  Executes the command
  """
  @callback execute(Wordle.t(), map()) :: Wordle.t()
end
