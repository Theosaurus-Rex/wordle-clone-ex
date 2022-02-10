defmodule DictionaryTest do
  use ExUnit.Case
  test "returns true for a valid guess word" do
    assert Dictionary.validate_guess("house") == true
  end

  test "returns false for an invalid guess word" do
    assert Dictionary.validate_guess("asdfg") == false
  end
end
