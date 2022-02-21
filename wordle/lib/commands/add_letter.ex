defmodule Wordle.Command.AddLetter do
  @behaviour Wordle.Command

  defstruct [:letter]

  @impl Wordle.Command
  def execute(state = %{current_game: current_game}, %{letter: letter}) do
    %Wordle{state | current_game: Game.add_letter(current_game, letter)}
  end

  # def undo(application_state, payload) do
  #   %Wordle{application_state | current_game: nil}
  # end
end
