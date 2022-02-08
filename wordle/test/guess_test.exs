defmodule GuessTest do
  use ExUnit.Case
  doctest Guess

  test "correct guess of one letter word" do
    assert Guess.guess("a", "a") == [correct: "a"]
  end

  test "incorrect guess of one letter word" do
    assert Guess.guess("b", "a") == [incorrect: "b"]
  end

  test "correct guess of multiletter word" do
    assert Guess.guess("bee", "bee") == [correct: "b", correct: "e", correct: "e"]
  end

  test "incorrect guess of multiletter word" do
    assert Guess.guess("cat", "dog") == [incorrect: "c", incorrect: "a", incorrect: "t"]
  end

  test "one letter matches guess of multiletter word" do
    assert Guess.guess("for", "dog") == [incorrect: "f", correct: "o", incorrect: "r"]
  end

  test "letter in word but in wrong place" do
    assert Guess.guess("out", "for") == [partial: "o", incorrect: "u", incorrect: "t"]
  end

  test "multiple letters in word in wrong places" do
    assert Guess.guess("dgo", "fog") == [incorrect: "d", partial: "g", partial: "o"]
  end

  test "multiples of one letter in guess" do
    assert Guess.guess("oto", "for") == [partial: "o", incorrect: "t", incorrect: "o"]
  end

  test "multiples of multiple letters in guess" do
    assert Guess.guess("otto", "toot") == [partial: "o", partial: "t", partial: "t", partial: "o"]
  end

  test "multiple letter in secret word match one letter in guess" do
    assert Guess.guess("doggo", "adder") == [partial: "d", incorrect: "o", incorrect: "g", incorrect: "g", incorrect: "o"]
  end

  test "guess shorter than secret word length throws an error" do
    assert Guess.guess("cat", "lizard") == {:error, :guess_too_short}
  end

  test "guess longer than secret word length throws an error" do
    assert Guess.guess("lizard", "cat") == {:error, :guess_too_long}
  end

  # test "player guess is compared to secret word when entered" do
  #   assert Guess.get_player_guess("words") == Guess.guess("words")
  # end
end
