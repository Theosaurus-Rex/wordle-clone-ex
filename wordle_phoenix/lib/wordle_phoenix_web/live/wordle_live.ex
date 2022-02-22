defmodule WordlePhoenixWeb.WordleLive do
  use WordlePhoenixWeb, :live_view
  use Phoenix.Component

  @debug true

  @commands Behaviour.Reflection.impls(Wordle.Command)
            |> Enum.map(fn mod ->
              p = apply(mod, :sample_payload, [])
              name = mod |> to_string |> String.split(".") |> List.last()
              {mod, %{name: name, module: mod, sample_payload: p}}
            end)

  @command_map @commands |> Enum.into(%{})

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:state, %Wordle{})
     |> assign(:current_command, Wordle.Command.CreateGame)
     |> assign(:commands, @commands)}
  end

  @impl true
  def handle_event("select_command", value, socket) do
    IO.inspect(value: value)
  end

  def render(assigns) do
    ~H"""
    <section>
      <.form let={f} for={@current_command} phx-change="select_command" phx-submit="select_command">
        <%= label f, :command, class: "block text-sm font-medium text-gray-700" %>
        <%= select f, :command, @commands %>
        <%= error_tag f, :command %>
      </.form>

      <!--
        <label for="command" class="block text-sm font-medium text-gray-700">Command</label>

        <select phx-change="select_command" id="command" name="command" class="mt-1 block w-full pl-3 pr-10 py-2 text-base border-gray-300 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm rounded-md">
          <%= for {command_name, command} <- @commands do %>
            <option><%= command_name %></option>
          <% end %>
        </select>
      </div>
      -->
    </section>
    <.debug {assigns} />
    """
  end

  def debug(assigns) do
    if @debug do
      ~H"""
      <div class="flex flex-col items-center pt-12">
        <div class="prose">
          <pre><code>
            <%= Code.format_string!(inspect(@current_command)) %>

            <%= Code.format_string!(inspect(@commands)) %>

            <%= Code.format_string!(inspect(@state)) %>
          </code></pre>
        </div>
      </div>
      """
    else
      ~H"""
      """
    end
  end
end
