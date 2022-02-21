defmodule WordlePhoenixWeb.GameLive do
  use WordlePhoenixWeb, :live_view
  use Phoenix.Component

  # Optionally also bring the HTML helpers
  # use Phoenix.HTML

  @debug true

  @colors %{
    initial: "bg-gray-800 text-white",
    correct: "bg-green-500 text-gray-900",
    partial: "bg-yellow-500 text-gray-900",
    incorrect: "bg-gray-900 text-white"
  }

  @keyboard_colors %{
    initial: "bg-gray-400 text-white",
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

  def keyboard_key(assigns) do
    status =
      if String.length(assigns.value) == 1 && assigns.value not in assigns.remaining_letters,
        do: :incorrect,
        else: :initial

    color_classes = @keyboard_colors[status]

    ~H"""
    <kbd
      phx-click="keyboard"
      phx-value-key={@value}
      class={"#{color_classes} p-4 rounded-md uppercase"}><%= @label %></kbd>
    """
  end

  def keyboard_row(assigns) do
    ~H"""
    <div class="m-5">
      <%= for {value, label} <- @key_values do %>
        <.keyboard_key value={value} label={label} remaining_letters={@remaining_letters} />
      <% end %>
    </div>
    """
  end

  def keyboard(assigns) do
    ~H"""
    <div id="keyboard" class="flex flex-col items-center mt-24">
      <.keyboard_row remaining_letters={@remaining_letters} key_values={letters_to_key_values("qwertyuiop")} />
      <.keyboard_row remaining_letters={@remaining_letters} key_values={letters_to_key_values("asdfghjkl")} />
      <.keyboard_row remaining_letters={@remaining_letters} key_values={[{"Back", "Back"}] ++ letters_to_key_values("zxcvbnm") ++ [{"Enter", "Enter"}]} />
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

  def letters_to_key_values(letters) do
    letters
    |> String.split("", trim: true)
    |> Enum.map(fn letter -> {letter, letter} end)
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

    ~H"""
    <section class="bg-gray-700 w-screen h-screen">
      <div class="flex flex-col text-gray-400 items-center pt-12">
        <%= for word_guess <- Enum.reverse(@game_state.guesses) do %>
          <.row word_guess={word_guess} />
        <% end %>
        <.row word_guess={new_guess} />
      </div>

      <.keyboard remaining_letters={@game_state.remaining_letters} />

      <.game_state game_state={@game_state} />
    </section>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :game_state, Game.new())}
  end

  def validate_input(word_guess) do
    if String.length(word_guess) < 5 do
      {:error}
    else
      {:ok}
    end
  end

  # TODO: Stop player from guessing if max_guesses reached OR if correct word guessed
  def check_guesses(game, guesses) do
    if length(guesses) >= game.max_turns do
      {:lose}
    else
      {:continue}
    end
  end

  def submit_guess(game, socket) do
    case validate_input(game.current_guess) do
      {:error} ->
        {:noreply, socket}

      _ ->
        {:noreply, assign(socket, :game_state, Game.make_guess(game, game.current_guess))}
    end
  end

  @impl true
  def handle_event("submit_guess", _key, socket) do
    {:noreply, socket}
  end

  def handle_event("keyboard", %{"key" => key}, socket) do
    game = socket.assigns.game_state

    case key do
      "Back" ->
        {:noreply, assign(socket, :game_state, Game.remove_letter(game))}

      "Enter" ->
        submit_guess(game, socket)

      letter ->
        {:noreply, assign(socket, :game_state, Game.add_letter(game, String.downcase(letter)))}
    end
  end
end
