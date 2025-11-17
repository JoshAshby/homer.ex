defmodule Homer.Zones.LivingRoom do
  @moduledoc false

  use Supervisor

  @impl true
  def start_link(params) do
    Supervisor.start_link(__MODULE__, params, name: __MODULE__)
  end

  @impl true
  def init(params) do
    children = [
      {Homer.Automations.Motion,
        consumes: consumes(:motion),
        produces: "homekit/house/zones/living-room/motion"},
      {Homer.Automations.Occupancy,
        consumes: consumes(:occupancy),
        produces: "homekit/house/zones/living-room/occupancy",
        timeout: 10},
    ]

    opts = [strategy: :one_for_one, name: __MODULE__.Supervisor]
    Supervisor.init(children, opts)
  end

  def consumes(:motion), do: [
    "zigbee/living-room/motion/#",
    "zigbee/dining-room/motion/#",
  ]

  def consumes(:occupancy), do: [
    "homekit/house/zones/living-room/motion",
  ]
end
