defmodule Wordle.Command do
  @doc """
  Executes the command
  """
  @callback execute(Wordle.t(), map()) :: Wordle.t()

  @doc """
  Provides a working example payload to pass to the command
  """
  @callback sample_payload() :: map()
end
