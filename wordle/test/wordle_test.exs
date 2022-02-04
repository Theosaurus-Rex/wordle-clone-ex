defmodule WordleTest do
  use ExUnit.Case
  doctest Wordle

  test "correct guess of one letter word" do
    assert Wordle.guess("a", "a") == [correct: "a"]
  end

  test "incorrect guess of one letter word" do
    assert Wordle.guess("b", "a") == [incorrect: "b"]
  end

  test "correct guess of multiletter word" do
    assert Wordle.guess("bee", "bee") == [correct: "b", correct: "e", correct: "e"]
  end

  test "incorrect guess of multiletter word" do
    assert Wordle.guess("cat", "dog") == [incorrect: "c", incorrect: "a", incorrect: "t"]
  end

  test "one letter matches guess of multiletter word" do
    assert Wordle.guess("for", "dog") == [incorrect: "f", correct: "o", incorrect: "r"]
  end

  test "letter in word but in wrong place" do
    assert Wordle.guess("out", "for") == [partial: "o", incorrect: "u", incorrect: "t"]
  end

  test "multiple letters in word in wrong places" do
    assert Wordle.guess("dgo", "fog") == [incorrect: "d", partial: "g", partial: "o"]
  end

  test "multiples of one letter in guess" do
    assert Wordle.guess("oto", "for") == [partial: "o", incorrect: "t", incorrect: "o"]
  end

  test "multiples of multiple letters in guess" do
    assert Wordle.guess("toot", "otto") == [partial: "t", partial: "o", partial: "o", partial: "t"]
  end
end
