defmodule Homer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      HomerWeb.Telemetry,
      Homer.Repo,
      {DNSCluster, query: Application.get_env(:homer, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Homer.PubSub},
      # Start a worker by calling: Homer.Worker.start_link(arg)
      # {Homer.Worker, arg},
      # Start to serve requests, typically the last entry
      HomerWeb.Endpoint,

      # Listeners,
      Homer.MQTT,

      # Schedules
      Homer.Scheduler,
      Homer.Schedules.Morning,
      Homer.Schedules.Evening,
      Homer.Schedules.Nightowl,

      # Zones
      Homer.Zones.Basement,
      Homer.Zones.Kitchen,
      Homer.Zones.LivingRoom,
      #Homer.Zones.Bedroom,
      #Homer.Zones.Office,
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Homer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    HomerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
