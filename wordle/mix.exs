defmodule Wordle.MixProject do
  use Mix.Project

  def project do
    [
      app: :wordle,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  def deps do
    [
      {:ex_doc, "~> 0.27", only: :dev, runtime: false},
      {:kino, "~> 0.5.2"},
      {:type_check, "~> 0.10.0"},
      {:stream_data, "~> 0.5.0", only: :test},
    ]
  end
end
