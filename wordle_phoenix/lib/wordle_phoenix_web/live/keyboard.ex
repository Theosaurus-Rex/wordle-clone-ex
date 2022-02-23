defmodule Wordle.Keyboard do
  # If you generated an app with mix phx.new --live,
  # the line below would be: use MyAppWeb, :live_component
  use Phoenix.Component

  @keyboard_colors %{
    initial: "bg-gray-400 text-white",
    correct: "bg-green-500 text-gray-900",
    partial: "bg-yellow-500 text-gray-900",
    incorrect: "bg-gray-900 text-white"
  }

  def keyboard(assigns) do
    ~H"""
    <div phx-keyup="keyboard" class="flex flex-col items-center space-y-7 lg:space-y-10 mt-24">
      <.row remaining_letters={@remaining_letters} key_values={letters_to_key_values("qwertyuiop")} />
      <.row remaining_letters={@remaining_letters} key_values={letters_to_key_values("asdfghjkl")} />
      <.row remaining_letters={@remaining_letters} key_values={[{"Backspace", "Back"}] ++ letters_to_key_values("zxcvbnm") ++ [{"Enter", "Enter"}]} />
    </div>
    """
  end

  def row(assigns) do
    ~H"""
    <div class="">
      <%= for {value, label} <- @key_values do %>
        <.key value={value} label={label} remaining_letters={@remaining_letters} />
      <% end %>
    </div>
    """
  end

  def key(assigns) do
    status =
      if String.length(assigns.value) == 1 && assigns.value not in assigns.remaining_letters,
        do: :incorrect,
        else: :initial

    color_classes = @keyboard_colors[status]

    ~H"""
    <kbd
      phx-click="keyboard"
      phx-value-key={@value}
      class={"#{color_classes} p-3 lg:p-4 rounded-md uppercase"}><%= @label %></kbd>
    """
  end

  def letters_to_key_values(letters) do
    letters
    |> String.split("", trim: true)
    |> Enum.map(fn letter -> {letter, letter} end)
  end
end
