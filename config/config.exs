# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :e_commerce,
  ecto_repos: [ECommerce.Repo],
  generators: [timestamp_type: :utc_datetime],
  payos_client_id:
    System.get_env("PAYOS_CLIENT_ID") ||
      raise("environment variable PAYOS_CLIENT_ID is missing."),
  payos_api_key:
    System.get_env("PAYOS_API_KEY") ||
      raise("environment variable PAYOS_API_KEY is missing."),
  payos_checksum_key:
    System.get_env("PAYOS_CHECKSUM_KEY") ||
      raise("environment variable PAYOS_CHECKSUM_KEY is missing.")

# Configures the endpoint
config :e_commerce, ECommerceWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: ECommerceWeb.ErrorHTML, json: ECommerceWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: ECommerce.PubSub,
  live_view: [signing_salt: "br1YZLNH"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :e_commerce, ECommerce.Mailer, adapter: Swoosh.Adapters.Local
config :e_commerce, :smtp_username, System.fetch_env!("SMTP_USERNAME")

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  e_commerce: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.3",
  e_commerce: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Elixir native JSON for JSON parsing in Phoenix
config :phoenix, :json_library, JSON
config :swoosh, :json_library, JSON

# Config timezone database
config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
