defmodule WordlePhoenixWeb.GameLive do
  use WordlePhoenixWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <section class="bg-gray-700 w-screen h-screen">
      <%
        guess_chars = String.pad_trailing(@game_state.current_guess, 5) |> String.to_charlist()
        new_guess = Enum.map(guess_chars,
          fn
            32 -> {:initial, raw("&nbsp;")}
            letter -> {:initial, to_string([letter])}
          end)
      %>
            <!-- TODO: Convert input to show up in blank guess row -->


            <!-- TODO: Compartmentalize template code into components -->
      <div class="flex flex-col text-gray-400 items-center pt-12">
        <%= for word_guess <- Enum.reverse(@game_state.guesses) do %>
          <div class="inline-block m-5">
              <%= for letter_guess <- word_guess do %>
                  <% {status, letter} = letter_guess %>
                  <% colors=%{
                      initial: "bg-gray-800 text-white",
                      correct: "bg-green-500 text-gray-900",
                      partial: "bg-yellow-500 text-gray-900",
                      incorrect: "bg-gray-900 text-white"
                  } %>
                  <kbd class={"rounded-md px-5 py-4 border border-slate-700 uppercase #{colors[status]}"}><%= letter %></kbd>
              <% end %>
          </div>
        <% end %>
        <div class="inline-block m-5">
            <%= for letter_guess <- new_guess do %>
                  <% {status, letter} = letter_guess %>
                  <% colors=%{
                      initial: "bg-gray-800 text-white",
                      correct: "bg-green-500 text-gray-900",
                      partial: "bg-yellow-500 text-gray-900",
                      incorrect: "bg-gray-900 text-white"
                  } %>
                  <kbd class={"rounded-md px-5 py-4 border border-slate-700 uppercase #{colors[status]}"}><%= letter %></kbd>
            <% end %>
        </div>
      </div>
      <div id="keyboard" class="flex flex-col items-center">
        <div id="keyboard-top-row" class="m-5">
          <kbd phx-click="keyboard" phx-value-key="Q" class="bg-gray-400 p-3 rounded-sm">Q</kbd>
          <kbd phx-click="keyboard" phx-value-key="W" class="bg-gray-400 p-3 rounded-sm">W</kbd>
          <kbd phx-click="keyboard" phx-value-key="E" class="bg-gray-400 p-3 rounded-sm">E</kbd>
          <kbd phx-click="keyboard" phx-value-key="R" class="bg-gray-400 p-3 rounded-sm">R</kbd>
          <kbd phx-click="keyboard" phx-value-key="T" class="bg-gray-400 p-3 rounded-sm">T</kbd>
          <kbd phx-click="keyboard" phx-value-key="Y" class="bg-gray-400 p-3 rounded-sm">Y</kbd>
          <kbd phx-click="keyboard" phx-value-key="U" class="bg-gray-400 p-3 rounded-sm">U</kbd>
          <kbd phx-click="keyboard" phx-value-key="I" class="bg-gray-400 p-3 rounded-sm">I</kbd>
          <kbd phx-click="keyboard" phx-value-key="O" class="bg-gray-400 p-3 rounded-sm">O</kbd>
          <kbd phx-click="keyboard" phx-value-key="P" class="bg-gray-400 p-3 rounded-sm">P</kbd>
        </div>
        <div id="keyboard-middle-row" class="m-5">
          <kbd phx-click="keyboard" phx-value-key="A" class="bg-gray-400 p-3 rounded-sm">A</kbd>
          <kbd phx-click="keyboard" phx-value-key="S" class="bg-gray-400 p-3 rounded-sm">S</kbd>
          <kbd phx-click="keyboard" phx-value-key="D" class="bg-gray-400 p-3 rounded-sm">D</kbd>
          <kbd phx-click="keyboard" phx-value-key="F" class="bg-gray-400 p-3 rounded-sm">F</kbd>
          <kbd phx-click="keyboard" phx-value-key="G" class="bg-gray-400 p-3 rounded-sm">G</kbd>
          <kbd phx-click="keyboard" phx-value-key="H" class="bg-gray-400 p-3 rounded-sm">H</kbd>
          <kbd phx-click="keyboard" phx-value-key="J" class="bg-gray-400 p-3 rounded-sm">J</kbd>
          <kbd phx-click="keyboard" phx-value-key="K" class="bg-gray-400 p-3 rounded-sm">K</kbd>
          <kbd phx-click="keyboard" phx-value-key="L" class="bg-gray-400 p-3 rounded-sm">L</kbd>
        </div>
        <div id="keyboard-bottom-row" class="m-5">
          <kbd phx-click="keyboard" phx-value-key="Enter" class="bg-gray-400 p-3 rounded-sm">ENTER</kbd>
          <kbd phx-click="keyboard" phx-value-key="Z" class="bg-gray-400 p-3 rounded-sm">Z</kbd>
          <kbd phx-click="keyboard" phx-value-key="X" class="bg-gray-400 p-3 rounded-sm">X</kbd>
          <kbd phx-click="keyboard" phx-value-key="C" class="bg-gray-400 p-3 rounded-sm">C</kbd>
          <kbd phx-click="keyboard" phx-value-key="V" class="bg-gray-400 p-3 rounded-sm">V</kbd>
          <kbd phx-click="keyboard" phx-value-key="B" class="bg-gray-400 p-3 rounded-sm">B</kbd>
          <kbd phx-click="keyboard" phx-value-key="N" class="bg-gray-400 p-3 rounded-sm">N</kbd>
          <kbd phx-click="keyboard" phx-value-key="M" class="bg-gray-400 p-3 rounded-sm">M</kbd>
          <kbd phx-click="keyboard" phx-value-key="Back" class="bg-gray-400 p-3 rounded-sm">BACK</kbd>
        </div>
      </div>

      <div class="flex flex-col items-center pt-12">
        <div class="prose">
        <pre class="">
          <code>
            <%= Code.format_string!(inspect(@game_state)) %>
          </code>
        </pre>
      </div></div>
    </section>

    <!-- TODO: Keyboard for mobile users -->
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
