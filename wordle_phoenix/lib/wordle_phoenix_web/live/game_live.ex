defmodule WordlePhoenixWeb.GameLive do
  use WordlePhoenixWeb, :live_view

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

      <div class="flex flex-col text-gray-400 items-center pt-12">
        <%= for word_guess <- @game_state.guesses do %>
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
end
