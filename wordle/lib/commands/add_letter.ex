defmodule Wordle.Command.AddLetter do
  @behaviour Wordle.Command

  defstruct [:letter]

  @sample_payload %{letter: "s"}

  @impl Wordle.Command
  def sample_payload() do
    @sample_payload
  end

  @impl Wordle.Command
  def execute(state = %{current_game: nil}, _) do
    %Wordle{state | error: "no current game"}
  end

  def execute(state = %{current_game: current_game}, %{letter: letter}) do
    %Wordle{state | current_game: Game.add_letter(current_game, letter)}
  end

  # def undo(application_state, payload) do
  #   %Wordle{application_state | current_game: nil}
  # end
end
