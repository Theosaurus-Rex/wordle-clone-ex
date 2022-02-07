defmodule GameTest do
  use ExUnit.Case
  doctest Game

  test "a new function should return a new instance of game" do
    assert Game.new() == %Game{}
  end

  test "a function sets secret word from dictionary" do
    game = Game.new |> Game.set_secret()
    assert Enum.member?(game.dictionary, game.secret_word)
  end

  test "the player guess is added to guesses list" do
    game = Game.new
    game = Game.add_guess(game, [correct: "d", correct: "o", correct: "g"])
    assert Enum.member?(game.guesses, [correct: "d", correct: "o", correct: "g"])
  end
end
