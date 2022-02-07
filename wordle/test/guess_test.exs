defmodule GuessTest do
  use ExUnit.Case
  doctest Guess

  test "correct guess_word of one letter word" do
    assert Guess.guess_word("a", "a") == [correct: "a"]
  end

  test "incorrect guess_word of one letter word" do
    assert Guess.guess_word("b", "a") == [incorrect: "b"]
  end

  test "correct guess_word of multiletter word" do
    assert Guess.guess_word("bee", "bee") == [correct: "b", correct: "e", correct: "e"]
  end

  test "incorrect guess_word of multiletter word" do
    assert Guess.guess_word("cat", "dog") == [incorrect: "c", incorrect: "a", incorrect: "t"]
  end

  test "one letter matches guess_word of multiletter word" do
    assert Guess.guess_word("for", "dog") == [incorrect: "f", correct: "o", incorrect: "r"]
  end

  test "letter in word but in wrong place" do
    assert Guess.guess_word("out", "for") == [partial: "o", incorrect: "u", incorrect: "t"]
  end

  test "multiple letters in word in wrong places" do
    assert Guess.guess_word("dgo", "fog") == [incorrect: "d", partial: "g", partial: "o"]
  end

  test "multiples of one letter in guess_word" do
    assert Guess.guess_word("oto", "for") == [partial: "o", incorrect: "t", incorrect: "o"]
  end

  test "multiples of multiple letters in guess_word" do
    assert Guess.guess_word("toot", "otto") == [partial: "t", partial: "o", partial: "o", partial: "t"]
  end
end
