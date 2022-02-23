require Protocol

Protocol.derive(Jason.Encoder, Wordle)
Protocol.derive(Jason.Encoder, Game)

defmodule TupleEncoder do
  alias Jason.Encoder

  defimpl Encoder, for: Tuple do
    def encode(data, options) when is_tuple(data) do
      data
      |> Tuple.to_list()
      |> Encoder.List.encode(options)
    end
  end
end

defmodule WordlePhoenixWeb.WordleLive do
  use WordlePhoenixWeb, :live_view
  use Phoenix.Component

  @debug false

  @commands Behaviour.Reflection.impls(Wordle.Command)
            |> Enum.map(fn mod ->
              p = apply(mod, :sample_payload, [])
              name = mod |> to_string |> String.split(".") |> List.last()
              {name, %{name: name, module: mod, sample_payload: p}}
            end)
            |> Enum.into(%{})

  @command_options Behaviour.Reflection.impls(Wordle.Command)
                   |> Enum.map(fn mod ->
                     name = mod |> to_string |> String.split(".") |> List.last()
                     {name, name}
                   end)

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:state, %Wordle{})
     |> assign(:current_command, nil)
     |> assign(:current_payload, nil)
     |> assign(:command_options, @command_options)
     |> assign(:commands, @commands)
     |> assign(:selected_command_id, nil)
     |> assign(:history, [])}
  end

  @impl true
  def handle_event(
        "validate",
        %{"command_form" => %{"command" => command_name, "payload" => payload}},
        socket
      ) do
    if command_name == socket.assigns.current_command do
      {:noreply,
       socket
       |> assign(:current_payload, payload)}
    else
      {:noreply,
       socket
       |> assign(:current_command, command_name)
       |> assign(
         :current_payload,
         Jason.encode!(@commands[command_name].sample_payload, pretty: true)
       )}
    end
  end

  @impl true
  def handle_event("execute", _, socket) do
    old_state = socket.assigns.state
    cmd = @commands[socket.assigns.current_command]
    payload = Jason.decode!(socket.assigns.current_payload, keys: :atoms!)
    new_state = apply(cmd.module, :execute, [old_state, payload])

    {:noreply,
     socket
     |> assign(:state, new_state)
     |> assign(:history, [
       {socket.assigns.current_command, payload, new_state} | socket.assigns.history
     ])}
  end

  @impl true
  def handle_event("show_command", %{"id" => id}, socket) do
    {:noreply,
     socket
     |> assign(:selected_command_id, String.to_integer(id))}
  end

  def render(assigns) do
    ~H"""
    <div class="flex space-x-5">
      <section class="flex flex-col space-y-5 m-8">
        <.form let={f} for={:command_form} phx-change="validate" phx-submit="execute" class="flex flex-col space-y-2">
          <%= select f, :command, @command_options,
                prompt: "Select Command",
                selected: @current_command,
                class: "block w-full pl-3 pr-10 py-2 text-base border-gray-300 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm rounded-md" %>
          <%= error_tag f, :command %>

          <%= textarea f, :payload, value: @current_payload,
                rows: "10", cols: "50",
                class: "block w-full pl-3 pr-10 py-2 text-base border-gray-300 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm rounded-md" %>
          <%= error_tag f, :payload %>

          <%= submit "Execute", class: "w-[20%] bg-blue-800 px-3 py-2 rounded-md text-white" %>
        </.form>
      </section>
      <.command_history history={@history} selected_command_id={@selected_command_id} />

      <.live_component module={WordlePhoenixWeb.GameComponent} id="game" game_state={@state.current_game || Game.new()} />
    </div>
    <.debug {assigns} />
    """
  end

  def command_history(assigns) do
    id = assigns.selected_command_id

    current_state =
      if id do
        {_, _, state} = Enum.fetch!(assigns.history, id)
        state
      end

    ~H"""
    <div class="flex flex-row space-x-5">
      <ul role="list" class=" divide-y divide-gray-200">
        <%= Enum.with_index(@history, fn {command_name, payload, state}, index -> %>
          <.command id={index} name={command_name} payload={payload} selected={index == @selected_command_id} />
        <% end) %>
      </ul>
      <pre class="whitespace-pre"><code class="text-sm text-gray-500">
        <%= current_state && Jason.encode!(current_state, pretty: true) %>
      </code></pre>
    </div>
    """
  end

  def command(assigns) do
    ~H"""
    <li phx-click="show_command" phx-value-id={@id} class={"p-2 #{if @selected, do: "bg-blue-100", else: ""}"}>
      <div class="flex space-x-3">
        <div class="flex-1 space-y-1">
          <div class="flex items-center justify-between">
            <h3 class="text-sm font-medium"><%= @id %>: <%= @name %></h3>
            <pre class="whitespace-normal"><code class="text-sm text-gray-500">
              <%= Jason.encode!(@payload) %>
            </code></pre>
          </div>
        </div>
      </div>
    </li>
    """
  end

  def debug(assigns) do
    if @debug do
      ~H"""
      <div class="flex flex-col items-center pt-12">
        <div class="prose prose-sm prose-slate">
          <pre><code>
            <%= Code.format_string!(inspect(@selected_command_id)) %>
            <%= Code.format_string!(inspect(@history)) %>
            <% Code.format_string!(inspect(@current_command)) %>
            <% Code.format_string!(inspect(@state)) %>
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
