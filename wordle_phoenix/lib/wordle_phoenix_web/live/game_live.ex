defmodule WordlePhoenixWeb.GameLive do
  use WordlePhoenixWeb, :live_view
  use Phoenix.Component

  # Optionally also bring the HTML helpers
  # use Phoenix.HTML

  @letters (Enum.to_list(?a..?z) ++ Enum.to_list(?A..?Z))
           |> to_string
           |> String.split("", trim: true)

  @debug true

  @colors %{
    initial: "bg-gray-800 text-white",
    correct: "bg-green-500 text-gray-900",
    partial: "bg-yellow-500 text-gray-900",
    incorrect: "bg-gray-900 text-white"
  }

  def square(assigns = %{letter_guess: {status, letter}}) do
    color_classes = @colors[status]

    ~H"""
    <kbd class={"rounded-md px-5 py-4 border border-slate-700 uppercase #{color_classes}"}><%= letter %></kbd>
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

  def game_state(assigns) do
    if @debug do
      ~H"""
      <div class="flex flex-col items-center pt-12">
        <div class="prose">
          <pre><code>
            <%= Code.format_string!(inspect(@game_state)) %>
          </code></pre>
        </div>
      </div>
      """
    else
      ~H"""
      """
    end
  end

  @impl true
  def render(assigns) do
    new_guess =
      assigns.game_state.current_guess
      |> String.pad_trailing(5)
      |> String.to_charlist()
      |> Enum.map(fn
        32 -> {:initial, raw("&nbsp;")}
        letter -> {:initial, to_string([letter])}
      end)

    rows =
      Enum.reverse(assigns.game_state.guesses) ++
        [new_guess] ++
        for _ <- 1..5, do: for(_ <- 1..5, do: {:initial, raw("&nbsp;")})

    ~H"""
    <section class="bg-gray-700 w-screen min-h-screen">
      <div class="flex flex-col text-gray-400 items-center pt-12">
        <%= for word_guess <- Enum.take(rows, 6) do %>
          <.row word_guess={word_guess} />
        <% end %>
      </div>

      <Wordle.Keyboard.keyboard remaining_letters={@game_state.remaining_letters} />

      <.game_state game_state={@game_state} />
    </section>
    """
  end

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
        {:noreply, assign(socket, :game_state, Game.make_guess(game, game.current_guess))}

      letter when letter in @letters ->
        {:noreply, assign(socket, :game_state, Game.add_letter(game, String.downcase(letter)))}

      _ ->
        {:noreply, socket}
    end
  end
end
