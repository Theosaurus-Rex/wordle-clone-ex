defmodule Wordle.CommandTest do
  use ExUnit.Case

  alias Wordle.Command.CreateGame
  alias Wordle.Command.AddLetter
  alias Wordle.Command.RemoveLetter
  alias Wordle.Command.MakeGuess

  test "CreateGame command" do
    state =
      %Wordle{}
      |> CreateGame.execute(%CreateGame{secret_word: "steps"})

    assert %Wordle{current_game: %Game{secret_word: "steps"}} = state
  end

  test "multiple CreateGame command should overwrite previous game" do
    state =
      %Wordle{}
      |> CreateGame.execute(%CreateGame{secret_word: "steps"})
      |> CreateGame.execute(%CreateGame{secret_word: "weird"})

    assert %Wordle{current_game: %Game{secret_word: "weird"}} = state
  end

  test "create game and add 2 letters" do
    state =
      %Wordle{}
      |> CreateGame.execute(%CreateGame{secret_word: "weird"})
      |> AddLetter.execute(%AddLetter{letter: "a"})
      |> AddLetter.execute(%AddLetter{letter: "b"})

    assert %Wordle{current_game: %Game{current_guess: "ab"}} = state
  end

  test "create game and add 5 letters removing incorrect letter x" do
    state =
      %Wordle{}
      |> CreateGame.execute(%CreateGame{secret_word: "weird"})
      |> AddLetter.execute(%AddLetter{letter: "w"})
      |> AddLetter.execute(%AddLetter{letter: "e"})
      |> AddLetter.execute(%AddLetter{letter: "i"})
      |> AddLetter.execute(%AddLetter{letter: "x"})
      |> RemoveLetter.execute(%RemoveLetter{})
      |> AddLetter.execute(%AddLetter{letter: "r"})
      |> AddLetter.execute(%AddLetter{letter: "d"})

    assert %Wordle{current_game: %Game{current_guess: "weird"}} = state
  end

  test "create game and add 5 letters and submit the guess" do
    state =
      %Wordle{}
      |> CreateGame.execute(%CreateGame{secret_word: "weird"})
      |> AddLetter.execute(%AddLetter{letter: "w"})
      |> AddLetter.execute(%AddLetter{letter: "e"})
      |> AddLetter.execute(%AddLetter{letter: "i"})
      |> AddLetter.execute(%AddLetter{letter: "r"})
      |> AddLetter.execute(%AddLetter{letter: "d"})
      |> MakeGuess.execute(%MakeGuess{})

    assert %Wordle{
             current_game: %Game{
               current_guess: "",
               guesses: [[correct: "w", correct: "e", correct: "i", correct: "r", correct: "d"]]
             }
           } = state
  end
end
