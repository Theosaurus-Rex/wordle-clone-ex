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

  test "multiple of same letter in guess but not in secret word" do
    assert Guess.guess("props", "shops") == [incorrect: "p", incorrect: "r", correct: "o", correct: "p", correct: "s"]
  end

  test "correct pass returns correct keys for letters that match" do
    assert Guess.correct_pass("d", "d") == {[correct: "d"], []}
  end

  test "correct pass returns incorrect keys for letters that don't match" do
    assert Guess.correct_pass("a", "d") == {[incorrect: "a"], [?d]}
  end

  test "correct pass returns multiple different letters with correct statuses" do
    assert Guess.correct_pass("dog", "fog") == {[incorrect: "d", correct: "o", correct: "g"], [?f]}
  end

  test "correct pass returns the correct statuses for guess of multiple of the same letter" do
    assert Guess.correct_pass("ddg", "dog") == {[correct: "d", incorrect: "d", correct: "g"], [?o]}
  end

  test "correct pass returns multiple of same letter in guess but not in secret word" do
    assert Guess.correct_pass("props", "shops") == {[incorrect: "p", incorrect: "r", correct: "o", correct: "p", correct: "s"], [?h, ?s]}
  end

  test "partial pass returns partial match for letters that are in the secret word but in the wrong place" do
    updated_state = {[incorrect: "d", incorrect: "o", incorrect: "t"], [?f, ?d, ?g]}
    assert Guess.partial_pass("dot", updated_state, "fdg") == {[partial: "d", incorrect: "o", incorrect: "t"] , [?g, ?f]}
  end
end
