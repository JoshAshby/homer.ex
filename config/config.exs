# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

config :home_auto,
  ecto_repos: [HomeAuto.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :home_auto, HomeAutoWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: HomeAutoWeb.ErrorHTML, json: HomeAutoWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: HomeAuto.PubSub,
  live_view: [signing_salt: "fiPfsTXe"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :home_auto, HomeAuto.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.25.4",
  home_auto: [
    args:
      ~w(js/app.js --bundle --target=es2022 --outdir=../priv/static/assets/js --external:/fonts/* --external:/images/* --alias:@=.),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => [Path.expand("../deps", __DIR__), Mix.Project.build_path()]}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "4.1.7",
  home_auto: [
    args: ~w(
      --input=assets/css/app.css
      --output=priv/static/assets/css/app.css
    ),
    cd: Path.expand("..", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :home_auto, HomeAuto.Scheduler,
  jobs: [
    # Every minute
    {"* * * * *", {HomeAuto.Ticker, :tick, []}},
  ]

config :home_auto, :emqtt,
  host: "boulder.local",
  port: 1883,
  clientid: "home_auto",
  clean_start: false,
  name: :emqtt

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
