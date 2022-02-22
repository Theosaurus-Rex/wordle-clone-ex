defmodule WordlePhoenixWeb.WordleLive do
  use WordlePhoenixWeb, :live_view
  use Phoenix.Component

  @debug true

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

  def render(assigns) do
    ~H"""
    <section class="flex flex-col space-y-5 m-8">
      <.form let={f} for={:command_form} phx-change="validate" phx-submit="execute" class="flex flex-col space-y-2">
        <%= select f, :command, @command_options,
              prompt: "Select Command",
              selected: @current_command,
              class: "block w-full pl-3 pr-10 py-2 text-base border-gray-300 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm rounded-md" %>
        <%= error_tag f, :command %>

        <%= textarea f, :payload, value: @current_payload,
              rows: "20", cols: "80",
              class: "block w-full pl-3 pr-10 py-2 text-base border-gray-300 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm rounded-md" %>
        <%= error_tag f, :payload %>

        <%= submit "Execute", class: "w-[20%] bg-blue-800 px-3 py-2 rounded-md text-white" %>
      </.form>
    </section>
    <.command_history history={@history} />
    <.debug {assigns} />
    """
  end

  def command_history(assigns) do
    ~H"""
    <div>
      <ul role="list" class="divide-y divide-gray-200">
        <li class="py-4">
          <div class="flex space-x-3">
            <img class="h-6 w-6 rounded-full" src="https://images.unsplash.com/photo-1517841905240-472988babdf9?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=facearea&facepad=3&w=256&h=256&q=80" alt="">
            <div class="flex-1 space-y-1">
              <div class="flex items-center justify-between">
                <h3 class="text-sm font-medium">Lindsay Walton</h3>
                <p class="text-sm text-gray-500">1h</p>
              </div>
              <p class="text-sm text-gray-500">Deployed Workcation (2d89f0c8 in master) to production</p>
            </div>
          </div>
        </li>
      </ul>
    </div>
    """
  end

  def debug(assigns) do
    if @debug do
      ~H"""
      <div class="flex flex-col items-center pt-12">
        <div class="prose prose-sm prose-slate">
          <pre><code>
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
