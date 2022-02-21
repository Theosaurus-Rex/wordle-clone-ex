defmodule GameTest do
  use ExUnit.Case

  test "new function should return a new instance of game" do
    game = Game.new("steps")
    assert game == %Game{secret_word: "steps"}
  end

  # TODO ability to set dictionary per game
  # test "new function sets secret word from dictionary" do
  #   dictionary = ["stone"]
  #   game = Game.new(dictionary: dictionary)
  #   assert Enum.member?(dictionary, game.secret_word)
  # end

  describe "assemble current guess with individual letters" do
    test "new game has no current guess" do
      assert %Game{current_guess: ""} = Game.new("steps")
    end

    test "add letter to new game" do
      game =
        Game.new("steps")
        |> Game.add_letter("a")

      assert %Game{current_guess: "a"} = game
    end

    test "can't remove letter if there aren't any" do
      game =
        Game.new("steps")
        |> Game.remove_letter()

      assert %Game{current_guess: ""} = game
    end

    test "can remove letter" do
      game =
        Game.new("steps")
        |> Game.add_letter("x")
        |> Game.add_letter("y")

      assert %Game{current_guess: "xy"} = game

      game =
        game
        |> Game.remove_letter()

      assert %Game{current_guess: "x"} = game
    end

    test "can remove multiple letters" do
      game =
        Game.new("steps")
        |> Game.add_letter("x")
        |> Game.add_letter("y")
        |> Game.add_letter("z")

      assert %Game{current_guess: "xyz"} = game

      game =
        game
        |> Game.remove_letter()
        |> Game.remove_letter()

      assert %Game{current_guess: "x"} = game
    end

    test "only remove one letter at a time" do
      game =
        Game.new("steps")
        |> Game.add_letter("x")
        |> Game.add_letter("x")
        |> Game.add_letter("x")

      assert %Game{current_guess: "xxx"} = game

      game =
        game
        |> Game.remove_letter()

      assert %Game{current_guess: "xx"} = game
    end

    test "can't add more letters than 5" do
      game =
        Game.new("steps")
        |> Game.add_letter("x")
        |> Game.add_letter("y")
        |> Game.add_letter("z")
        |> Game.add_letter("a")
        |> Game.add_letter("b")
        |> Game.add_letter("?")

      assert %Game{current_guess: "xyzab"} = game
    end

    test "can't add more than 1 letter at a time" do
      game =
        Game.new("steps")
        |> Game.add_letter("xy")

      assert %Game{current_guess: "x"} = game
    end
  end

  test "the player guess is added to guesses list" do
    game = Game.new("cat")
    game = Game.make_guess(game, "dog")
    assert Enum.member?(game.guesses, incorrect: "d", incorrect: "o", incorrect: "g")
  end

  test "displays game over message if maximum number of turns is reached" do
    game =
      Game.new("cat")
      |> Game.make_guess("dog")
      |> Game.make_guess("bat")
      |> Game.make_guess("toe")
      |> Game.make_guess("fee")
      |> Game.make_guess("tee")
      |> Game.make_guess("ten")

    assert game.turn_state == :lose
  end

  test "check if there are turns remaining to keep running the game" do
    game =
      Game.new("cat")
      |> Game.make_guess("dog")
      |> Game.make_guess("bat")
      |> Game.make_guess("toe")
      |> Game.make_guess("fee")
      |> Game.make_guess("tee")

    assert game.turn_state == :continue
  end

  test "game ends when player guesses the secret word" do
    game = Game.new("dog")
    game = Game.make_guess(game, "dog")
    assert game.turn_state == :win
  end

  test "check if last player guess is correct" do
    game = Game.new("dog")
    game = Game.make_guess(game, "dog")
    assert Game.correct_guess(game) == true
  end

  test "check if last player guess is incorrect" do
    game = Game.new("cat")
    game = Game.make_guess(game, "dog")
    assert Game.correct_guess(game) == false
  end

  test "check if last player guess has a partially correct letter" do
    game = Game.new("cat")
    game = Game.make_guess(game, "rat")
    assert Game.correct_guess(game) == false
  end

  test "check if player has lost at 6 turns" do
    game = Game.new("cat")

    game =
      Enum.reduce(1..6, game, fn _, acc ->
        Game.make_guess(acc, "dog")
      end)

    assert Game.check_loss(game) == true
  end

  test "check loss state if player has not taken any turns" do
    game = Game.new("stone")
    assert Game.check_loss(game) == false
  end

  test "check if player has turns remaining mid-game" do
    game = Game.new("cat")

    game =
      Enum.reduce(1..3, game, fn _, acc ->
        Game.make_guess(acc, "dog")
      end)

    assert Game.check_loss(game) == false
  end

  test "check turn result when result is a win" do
    game = Game.new("dog")
    game = Game.make_guess(game, "dog")
    game_result = Game.turn_result(game)
    assert game_result.turn_state == :win
  end

  test "check turn result when result is a loss" do
    game = Game.new("cat")

    game =
      Enum.reduce(1..6, game, fn _, acc ->
        Game.make_guess(acc, "dog")
      end)

    game_result = Game.turn_result(game)
    assert game_result.turn_state == :lose
  end

  test "check turn result when player has turns remaining" do
    game = Game.new("cat")

    game =
      Enum.reduce(1..3, game, fn _, acc ->
        Game.make_guess(acc, "dog")
      end)

    game_result = Game.turn_result(game)
    assert game_result.turn_state == :continue
  end

  test "guess_valid? returns ok when a valid guess is entered" do
    game = Game.new("frogs")
    assert Game.guess_valid?(game, "frogs") == {:ok, "frogs"}
  end

  test "guess_valid? returns error when a guess is too long" do
    game = Game.new("frogs")
    assert Game.guess_valid?(game, "tadpoles") == {:error, :guess_too_long}
  end

  test "guess_valid? returns error when a guess is too short" do
    game = Game.new("frogs")
    assert Game.guess_valid?(game, "egg") == {:error, :guess_too_short}
  end

  test "guess_valid? returns error when a guess is not in the dictionary" do
    game = Game.new("frogs")
    assert Game.guess_valid?(game, "asdfg") == {:error, :invalid_guess}
  end

  test "filter_remainders removes incorrect letters guesses from game state" do
    game = Game.new("house")

    assert Game.filter_remainders(game,
             incorrect: "g",
             incorrect: "r",
             partial: "o",
             partial: "u",
             incorrect: "t"
           ) == %Game{
             secret_word: "house",
             remaining_letters: [
               "a",
               "b",
               "c",
               "d",
               "e",
               "f",
               "h",
               "i",
               "j",
               "k",
               "l",
               "m",
               "n",
               "o",
               "p",
               "q",
               "s",
               "u",
               "v",
               "w",
               "x",
               "y",
               "z"
             ]
           }
  end
end
