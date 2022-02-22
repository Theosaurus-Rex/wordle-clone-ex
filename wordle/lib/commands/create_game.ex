defmodule Wordle.Command.CreateGame do
  @behaviour Wordle.Command

  defstruct [:secret_word, :max_guesses, :word_length]

  @sample_payload %{secret_word: "weird"}

  @impl Wordle.Command
  def sample_payload() do
    @sample_payload
  end

  @impl Wordle.Command
  def execute(application_state, %{secret_word: secret_word}) do
    %Wordle{application_state | current_game: Game.new(secret_word)}
  end

  # def undo(application_state, payload) do
  #   %Wordle{application_state | current_game: nil}
  # end
end