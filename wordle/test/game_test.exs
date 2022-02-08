defmodule GameTest do
  use ExUnit.Case


  test "a new function should return a new instance of game" do
    assert Game.new() == %Game{}
  end

  test "a function sets secret word from dictionary" do
    game = Game.new |> Game.set_secret()
    assert Enum.member?(game.dictionary, game.secret_word)
  end

  test "the player guess is added to guesses list" do
    game = Game.new |> Game.add_guess([correct: "d", correct: "o", correct: "g"])
    assert Enum.member?(game.guesses, [correct: "d", correct: "o", correct: "g"])
  end

  test "displays game over message if maximum number of terns is reached" do
   game = Game.new
   game = Enum.reduce(1..6, game, fn _, acc ->
      Game.add_guess(acc, [correct: "d", incorrect: "o", partial: "m"])
   end)
   assert Game.game_over(game) == "You reached the end of the game"
  end
end
