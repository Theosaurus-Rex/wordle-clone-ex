defmodule GameTest do
  use ExUnit.Case


  test "a new function should return a new instance of game" do
    assert Game.new() == %Game{}
  end

  test "a function sets secret word from dictionary" do
    game = Game.new
    game = Game.set_secret(game, Enum.random(game.dictionary))
    assert Enum.member?(game.dictionary, game.secret_word)
  end

  test "the player guess is added to guesses list" do
    game = Game.new
    game = Game.set_secret(game, "cat")
    game = Game.make_guess(game, "dog")
    assert Enum.member?(game.guesses, [incorrect: "d", incorrect: "o", incorrect: "g"])
  end

  test "displays game over message if maximum number of turns is reached" do
   game = Game.new
   game = Game.set_secret(game, "cat")
   game = Enum.reduce(1..6, game, fn _, acc ->
      Game.make_guess(acc, "dog")
   end)
   assert game.turn_state == :lose
  end

  test "check if there are turns remaining to keep running the game" do
    game = Game.new
    game = Game.set_secret(game, "cat")
    game = Enum.reduce(1..5, game, fn _, acc ->
      Game.make_guess(acc, "dog")
   end)
   assert game.turn_state == :continue
  end

  test "game ends when player guesses the secret word" do
    game = Game.new
    game = Game.set_secret(game, "dog")
    game = Game.make_guess(game, "dog")
    assert game.turn_state == :win
  end

  test "check if last player guess is correct" do
    game = Game.new
    game = Game.set_secret(game, "dog")
    game = Game.make_guess(game, "dog")
    assert Game.correct_guess(game) == true
  end

  test "check if last player guess is incorrect" do
    game = Game.new
    game = Game.set_secret(game, "cat")
    game = Game.make_guess(game, "dog")
    assert Game.correct_guess(game) == false
  end

  test "check if last player guess has a partially correct letter" do
    game = Game.new
    game = Game.set_secret(game, "cat")
    game = Game.make_guess(game, "rat")
    assert Game.correct_guess(game) == false
  end

  test "check if player has lost" do
    game = Game.new
    game = Game.set_secret(game, "cat")
    game = Enum.reduce(1..6, game, fn _, acc ->
      Game.make_guess(acc, "dog")
    end)
    assert Game.check_loss(game) == true
  end

  test "check loss state if player has not taken any turns" do
    game = Game.new
    assert Game.check_loss(game) == false
  end

  test "check if player has turns remaining mid-game" do
    game = Game.new
    game = Game.set_secret(game, "cat")
    game = Enum.reduce(1..3, game, fn _, acc ->
      Game.make_guess(acc, "dog")
    end)
    assert Game.check_loss(game) == false
  end

  test "check turn result when result is a win" do
    game = Game.new
    game = Game.set_secret(game, "dog")
    game = Game.make_guess(game, "dog")
    game_result = Game.turn_result(game)
    assert game_result.turn_state == :win
  end

  test "check turn result when result is a loss" do
    game = Game.new
    game = Game.set_secret(game, "cat")
    game = Enum.reduce(1..6, game, fn _, acc ->
      Game.make_guess(acc, "dog")
    end)
    game_result = Game.turn_result(game)
    assert game_result.turn_state == :lose
  end

  test "check turn result when player has turns remaining" do
    game = Game.new
    game = Game.set_secret(game, "cat")
    game = Enum.reduce(1..3, game, fn _, acc ->
      Game.make_guess(acc, "dog")
    end)
    game_result = Game.turn_result(game)
    assert game_result.turn_state == :continue
  end
end
