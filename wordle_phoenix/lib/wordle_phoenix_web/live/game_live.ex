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

            <input phx-keydown="submit_guess" type="text" minlength="5" maxlength="5"/>

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
    </section>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :game_state, Game.new("adieu"))}
  end

  def validate_input(word_guess) do
    if String.length(word_guess) < 5 do
      {:error}
    else
      {:ok}
    end
  end

  @impl true
  def handle_event("submit_guess", %{"value" => word_guess, "key" => "Enter"}, socket) do
    case validate_input(word_guess) do
      {:error} -> {:noreply, socket}
      _ -> {:noreply,
     assign(socket, :game_state, Game.make_guess(socket.assigns.game_state, word_guess))}
    end

  end

  def handle_event("submit_guess", _key, socket) do
    {:noreply,
     socket}
  end
end
