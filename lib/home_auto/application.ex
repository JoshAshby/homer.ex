defmodule HomeAuto.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      HomeAutoWeb.Telemetry,
      HomeAuto.Repo,
      {DNSCluster, query: Application.get_env(:home_auto, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: HomeAuto.PubSub},
      # Start a worker by calling: HomeAuto.Worker.start_link(arg)
      # {HomeAuto.Worker, arg},
      # Start to serve requests, typically the last entry
      HomeAutoWeb.Endpoint,
      # Listeners,
      HomeAuto.MQTT,

      # Schedules
      HomeAuto.Scheduler,
      HomeAuto.Schedules.Morning,
      HomeAuto.Schedules.Evening,
      HomeAuto.Schedules.Nightowl,

      # Automations
      {HomeAuto.Automations.Motion, zone: :basement,
        consumes: HomeAuto.Zones.Basement.topics(:motion),
        produces: "homekit/house/zones/basement/motion"},
      {HomeAuto.Automations.Occupancy, zone: :basement,
        timeout: 5,
        consumes: HomeAuto.Zones.Basement.topics(:occupancy),
        produces: "homekit/house/zones/basement/occupancy"},

      {HomeAuto.Automations.Motion, zone: :living_room,
        consumes: HomeAuto.Zones.LivingRoom.topics(:motion),
        produces: "homekit/house/zones/living-room/motion"},
      {HomeAuto.Automations.Occupancy, zone: :living_room,
        timeout: 5,
        consumes: HomeAuto.Zones.LivingRoom.topics(:occupancy),
        produces: "homekit/house/zones/living-room/occupancy"},

      {HomeAuto.Automations.Motion, zone: :kitchen,
        consumes: HomeAuto.Zones.Kitchen.topics(:motion),
        produces: "homekit/house/zones/kitchen/motion"},
      {HomeAuto.Automations.Occupancy, zone: :kitchen,
        timeout: 5,
        consumes: HomeAuto.Zones.Kitchen.topics(:occupancy),
        produces: "homekit/house/zones/kitchen/occupancy"},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: HomeAuto.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    HomeAutoWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
