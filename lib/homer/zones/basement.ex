defmodule Homer.Zones.Basement do
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
        produces: "homekit/house/zones/basement/motion"},
      {Homer.Automations.Occupancy,
        consumes: consumes(:occupancy),
        produces: "homekit/house/zones/basement/occupancy",
        timeout: 15},
    ]

    opts = [strategy: :one_for_one, name: __MODULE__.Supervisor]
    Supervisor.init(children, opts)
  end

  def consumes(:motion), do: [
    "zigbee/basement/motion/#",
    "zigbee/basement/presence/#",
    "homekit/house/basement/aqara-fp2-1/set/state",
  ]

  def consumes(:occupancy), do: [
    "homekit/house/zones/basement/motion",
  ]
end
