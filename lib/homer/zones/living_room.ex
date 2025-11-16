defmodule Homer.Zones.LivingRoom do
  @moduledoc false

  def topics(:motion), do: [
    "zigbee/living-room/motion/#",
    "zigbee/dining-room/motion/#",
  ]

  def topics(:occupancy), do: [
    "homekit/house/zones/livinig-room/motion",
  ]
end
