defmodule HomeAuto.Zones.LivingRoom do
  @moduledoc false

  def topic?(:motion, "zigbee/living-room/motion/" <> _), do: true
  def topic?(:motion, "zigbee/dining-room/motion/" <> _), do: true

  def topic?(:occupancy, "homekit/house/zones/livinig-room/motion"), do: true

  def topic?(_, _), do: false
end
