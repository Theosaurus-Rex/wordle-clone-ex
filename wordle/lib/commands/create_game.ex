defmodule Wordle.Command.CreateGame do
  @behaviour Wordle.Command

  defstruct [:secret_word, :max_guesses, :word_length]

  @impl Wordle.Command
  def execute(application_state, %__MODULE__{secret_word: secret_word}) do
    %Wordle{application_state | current_game: Game.new(secret_word)}
  end

  # def undo(application_state, payload) do
  #   %Wordle{application_state | current_game: nil}
  # end
end
