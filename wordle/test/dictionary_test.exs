defmodule DictionaryTest do
  use ExUnit.Case
  test "secret word comes from secret dictionary" do
    game = Game.new(Enum.random(Dictionary.secret_dictionary))
    assert Dictionary.validate_secret("aback") == true
  end

  test "secret word does not come from secret dictionary" do
    game = Game.new(Enum.random(Dictionary.secret_dictionary))
    assert Dictionary.validate_secret("sdhfk") == false
  end

  test "guess is valid if found in guess dictonary" do
    dictionary = Dictionary.guess_dictionary()
    assert Dictionary.validate_guess("aargh") == true
  end

  test "guess is invalid if not found in guess dictonary" do
    dictionary = Dictionary.guess_dictionary()
    assert Dictionary.validate_guess("askdf") == false
  end
end
