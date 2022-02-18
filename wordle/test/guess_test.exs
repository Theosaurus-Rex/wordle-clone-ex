defmodule GuessTest do
  use ExUnit.Case
  use TypeCheck.ExUnit

  spectest Guess

  doctest Guess

  test "correct guess of one letter word" do
    {status, _remainders} = Guess.guess("a", "a")
    assert status  == [correct: "a"]
  end

  test "incorrect guess of one letter word" do
    {status, _remainders} = Guess.guess("b", "a")
    assert status == [incorrect: "b"]
  end

  test "correct guess of multiletter word" do
    {status, _remainders} = Guess.guess("bee", "bee")
    assert status == [correct: "b", correct: "e", correct: "e"]
  end

  test "incorrect guess of multiletter word" do
    {status, _remainders} = Guess.guess("cat", "dog")
    assert status == [incorrect: "c", incorrect: "a", incorrect: "t"]
  end

  test "one letter matches guess of multiletter word" do
    {status, _remainders} = Guess.guess("for", "dog")
    assert status == [incorrect: "f", correct: "o", incorrect: "r"]
  end

  test "letter in word but in wrong place" do
    {status, _remainders} = Guess.guess("out", "for")
    assert status == [partial: "o", incorrect: "u", incorrect: "t"]
  end

  test "multiple letters in word in wrong places" do
    {status, _remainders} = Guess.guess("dgo", "fog")
    assert status == [incorrect: "d", partial: "g", partial: "o"]
  end

  test "multiples of one letter in guess" do
    {status, _remainders} = Guess.guess("oto", "for")
    assert  status == [partial: "o", incorrect: "t", incorrect: "o"]
  end

  test "multiples of multiple letters in guess" do
    {status, _remainders} = Guess.guess("otto", "toot")
    assert status == [partial: "o", partial: "t", partial: "t", partial: "o"]
  end

  test "multiple letter in secret word match one letter in guess" do
    {status, _remainders} = Guess.guess("doggo", "adder")
    assert  status == [partial: "d", incorrect: "o", incorrect: "g", incorrect: "g", incorrect: "o"]
  end

  test "multiple of same letter in guess but not in secret word" do
    {status, _remainders} = Guess.guess("props", "shops")
    assert status == [incorrect: "p", incorrect: "r", correct: "o", correct: "p", correct: "s"]
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
    {letter_state, remainders} = {[incorrect: "d", incorrect: "o", incorrect: "t"], [?f, ?d, ?g]}
    {status, _remainders} = Guess.partial_pass({letter_state, remainders}, "dot")
    assert status == [partial: "d", incorrect: "o", incorrect: "t"]
  end
end
