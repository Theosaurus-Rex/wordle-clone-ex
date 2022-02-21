defmodule Wordle.Command.RemoveLetter do
  @behaviour Wordle.Command

  defstruct []

  @impl Wordle.Command
  def execute(state = %{current_game: current_game}, _) do
    %Wordle{state | current_game: Game.remove_letter(current_game)}
  end

  # def undo(application_state, payload) do
  #   %Wordle{application_state | current_game: nil}
  # end
end
