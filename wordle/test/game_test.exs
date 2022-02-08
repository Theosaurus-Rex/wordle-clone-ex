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
   assert Game.game_over(game) == "GAME OVER!"
  end

  test "check if there are turns remaining to keep running the game" do
    game = Game.new
    game = Enum.reduce(1..5, game, fn _, acc ->
      Game.add_guess(acc, [correct: "d", incorrect: "o", partial: "m"])
   end)
   assert Game.game_over(game) == "Keep playing"
  end

  test "game ends when player guesses the secret word" do
    game = Game.new
    game = Game.add_guess(game, [correct: "d", correct: "o", correct: "m"])
    assert Game.win_game(game) == "YOU WON!"
  end

  test "the player guessed incorrect letter" do
    game = Game.new
    game = Game.add_guess(game, [incorrect: "o"])
    assert Game.win_game(game) == Game.game_over(game)
  end

  test "the player guessed partial letter" do
    game = Game.new
    game = Game.add_guess(game, [partial: "o"])
    assert Game.win_game(game) == Game.game_over(game)
  end

  test "the player guessed partial and incorrect letters" do
    game = Game.new
    game = Game.add_guess(game, [partial: "o", incorrect: "a"])
    assert Game.win_game(game) == Game.game_over(game)
  end


end
