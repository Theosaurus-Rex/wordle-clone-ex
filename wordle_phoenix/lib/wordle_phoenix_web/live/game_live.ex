defmodule WordlePhoenixWeb.GameLive do
  use WordlePhoenixWeb, :live_view
  use Phoenix.Component

  @letters (Enum.to_list(?a..?z) ++ Enum.to_list(?A..?Z))
           |> to_string
           |> String.split("", trim: true)

  @debug true

  @colors %{
    initial: "bg-gray-800 text-white",
    invalid_word: "bg-gray-800 text-red-500",
    correct: "bg-green-500 text-gray-900",
    partial: "bg-yellow-500 text-gray-900",
    incorrect: "bg-gray-900 text-white"
  }

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :game_state, Game.new())}
  end

  def handle_event("keyboard", %{"key" => key}, socket) do
    game = socket.assigns.game_state

    case key do
      "Backspace" ->
        {:noreply, assign(socket, :game_state, Game.remove_letter(game))}

      "Enter" ->
        case Game.guess_valid?(game, game.current_guess) do
          {:ok, _} ->
            {:noreply, assign(socket, :game_state, Game.make_guess(game))}

          {:error, _} ->
            {:noreply, socket}
        end

      letter when letter in @letters ->
        {:noreply, assign(socket, :game_state, Game.add_letter(game, String.downcase(letter)))}

      _ ->
        {:noreply, socket}
    end
  end

  @impl true
  def render(assigns) do
    letter_type =
      case Game.guess_valid?(assigns.game_state, assigns.game_state.current_guess) do
        {:error, :invalid_guess} -> :invalid_word
        _ -> :initial
      end

    new_guess =
      assigns.game_state.current_guess
      |> String.pad_trailing(5)
      |> String.to_charlist()
      |> Enum.map(fn
        32 -> {letter_type, raw("&nbsp;")}
        letter -> {letter_type, to_string([letter])}
      end)

    rows =
      Enum.reverse(assigns.game_state.guesses) ++
        [new_guess] ++
        for _ <- 1..5, do: for(_ <- 1..5, do: {:initial, raw("&nbsp;")})

    ~H"""
    <section phx-window-keyup="keyboard" class="bg-gray-700 w-screen min-h-screen flex flex-col items-center">
      <%= if @game_state.turn_state == :win do %>
      <div class="p-10 bg-green-300 rounded-md w-96">
        <p class="text-green-600 font-bold text-xl text-center">Congrats, you win!</p>
      </div>
      <% end %>
      <%= if @game_state.turn_state == :lose do %>
      <div class="p-10 bg-red-300 rounded-md w-96">
        <p class="text-red-600 font-bold text-xl text-center">Sorry, you lost! The secret word was "<%= @game_state.secret_word %>"</p>
      </div>
      <% end %>
      <div class="flex flex-col text-gray-400 items-center pt-12">
        <%= for word_guess <- Enum.take(rows, 6) do %>
          <.row word_guess={word_guess} />
        <% end %>
      </div>

      <Wordle.Keyboard.keyboard remaining_letters={@game_state.remaining_letters} />

    </section>
    """
  end

  def row(assigns) do
    ~H"""
    <div class="inline-block m-5">
      <%= for letter_guess <- @word_guess do %>
        <.square letter_guess={letter_guess} />
      <% end %>
    </div>
    """
  end

  def square(assigns = %{letter_guess: {status, letter}}) do
    color_classes = @colors[status]

    ~H"""
    <kbd class={"rounded-md px-5 py-4 border border-slate-700 uppercase #{color_classes}"}><%= letter %></kbd>
    """
  end
end
