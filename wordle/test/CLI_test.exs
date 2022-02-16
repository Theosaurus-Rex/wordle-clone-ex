defmodule CLITest do
  use ExUnit.Case

  test "returns ok status when a player guess is valid" do
    game = Game.new("couch")
    assert CLI.validate_guess(game, "couch") == {:ok, "couch"}
  end

  test "get_player_input gets the player guess" do
    assert CLI.get_player_input(FakeIO) == "shops"
  end

  test "player gets declare_win message when game status is win" do
    game = Game.new("couch")
    assert CLI.submit_guess(game, "couch") == "You win! The answer was #{game.secret_word}"
  end

  test "player gets declare_game_over message when game status is lose" do
    game = Game.new("couch")

    Enum.reduce(1..6, game, fn _, acc ->
      Game.make_guess(acc, "mouse")
    end)

    assert CLI.declare_game_over(game) ==
             "Game over! The answer was #{game.secret_word}. Better luck next time!"
  end

  test "player gets error message if guess is too long" do
    assert ExUnit.CaptureIO.capture_io(fn -> CLI.print_error(:guess_too_long) end) ==
             "Your guess was too long - try a different word\n\n"
  end

  test "player gets error message if guess is too short" do
    assert ExUnit.CaptureIO.capture_io(fn -> CLI.print_error(:guess_too_short) end) ==
             "Your guess was too short - try a different word\n\n"
  end

  test "player gets error message if an invalid guess is made" do
    assert ExUnit.CaptureIO.capture_io(fn -> CLI.print_error(:invalid_guess) end) ==
             "Please enter a valid word\n"
  end
end
