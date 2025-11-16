defmodule Homer.Zones.Basement do
  @moduledoc false

  def topics(:motion), do: [
    "zigbee/basement/motion/#",
    "zigbee/basement/presence/#",
    "homekit/house/basement/aqara-fp2-1/set/state",
  ]

  def topics(:occupancy), do: [
    "homekit/house/zones/basement/motion",
  ]
end
