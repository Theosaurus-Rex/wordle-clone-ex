defmodule Wordle.Command.RemoveLetter do
  @behaviour Wordle.Command

  defstruct []

  @sample_payload %{}

  @impl Wordle.Command
  def sample_payload() do
    @sample_payload
  end

  @impl Wordle.Command
  def execute(state = %{current_game: nil}, _) do
    %Wordle{state | error: "no current game"}
  end

  def execute(state = %{current_game: current_game}, _) do
    %Wordle{state | current_game: Game.remove_letter(current_game)}
  end

  # def undo(application_state, payload) do
  #   %Wordle{application_state | current_game: nil}
  # end
end
