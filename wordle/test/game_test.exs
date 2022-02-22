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

    test "at max turns we should not accept more letters" do
      game =
        Game.new("cat")
        |> Game.make_guess("dog")
        |> Game.make_guess("bat")
        |> Game.make_guess("toe")
        |> Game.make_guess("fee")
        |> Game.make_guess("tee")
        |> Game.make_guess("ten")
        |> Game.add_letter("x")

      assert length(game.guesses) == 6
      assert Game.check_loss(game) == true
      assert game.turn_state == :lose
      assert game.current_guess == ""
    end

    test "when we've won we should not accept more letters" do
      game =
        Game.new("cat")
        |> Game.make_guess("cat")
        |> Game.add_letter("x")

      assert length(game.guesses) == 1
      assert Game.check_loss(game) == false
      assert game.turn_state == :win
      assert game.current_guess == ""
    end
  end

  describe "make guess" do
    test "the player guess is added to guesses list" do
      game =
        Game.new("cat")
        |> Game.make_guess("dog")

      assert game.guesses == [[incorrect: "d", incorrect: "o", incorrect: "g"]]
    end

    test "not accepted if not enough letters" do
      game =
        Game.new("catch")
        |> Game.make_guess("dog")

      assert game.guesses == []
    end

    test "lose if maximum number of turns is reached" do
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
      assert Game.check_loss(game) == false
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

    test "check loss state if player has not taken any turns" do
      game = Game.new("stone")
      assert Game.check_loss(game) == false
    end
  end

  describe "guess_valid?" do
    test "returns ok when a valid guess is entered" do
      game = Game.new("frogs")
      assert Game.guess_valid?(game, "frogs") == {:ok, "frogs"}
    end

    test "returns error when a guess is too long" do
      game = Game.new("frogs")
      assert Game.guess_valid?(game, "tadpoles") == {:error, :guess_too_long}
    end

    test "returns error when a guess is too short" do
      game = Game.new("frogs")
      assert Game.guess_valid?(game, "egg") == {:error, :guess_too_short}
    end

    test "returns error when a guess is not in the dictionary" do
      game = Game.new("frogs")
      assert Game.guess_valid?(game, "asdfg") == {:error, :invalid_guess}
    end

    test "at max turns we should not accept more guesses" do
      game =
        Game.new("cat")
        |> Game.make_guess("dog")
        |> Game.make_guess("bat")
        |> Game.make_guess("toe")
        |> Game.make_guess("fee")
        |> Game.make_guess("tee")
        |> Game.make_guess("ten")
        |> Game.make_guess("get")

      assert length(game.guesses) == 6
      assert Game.check_loss(game) == true
      assert game.turn_state == :lose
      assert game.current_guess == ""
    end

    test "when won we should not accept more guesses" do
      game =
        Game.new("cat")
        |> Game.make_guess("cat")

      assert length(game.guesses) == 1
      assert Game.check_loss(game) == false
      assert game.turn_state == :win
      assert game.current_guess == ""
    end
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
