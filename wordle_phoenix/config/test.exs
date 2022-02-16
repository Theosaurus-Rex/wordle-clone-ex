import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :wordle_phoenix, WordlePhoenixWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "txekRXiaL57mfel/d3RoCU1m/zbMSW4W178a2YOVoiwaUaiHmwxW4e8qHWKPNZw4",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
