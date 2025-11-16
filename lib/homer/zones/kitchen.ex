defmodule Homer.Zones.Kitchen do
  @moduledoc false

  def topics(:motion), do: [
    "zigbee/kitchen/motion/#",
    "zigbee/kitchen/presence/#",
  ]

  def topics(:occupancy), do: [
    "homekit/house/zones/kitchen/motion",
  ]
end
