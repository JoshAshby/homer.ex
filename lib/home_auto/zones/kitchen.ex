defmodule HomeAuto.Zones.Kitchen do
  @moduledoc false

  def topic?(:motion, "zigbee/kitchen/motion/" <> _), do: true
  def topic?(:motion, "zigbee/kitchen/presence/" <> _), do: true

  def topic?(:occupancy, "homekit/house/zones/kitchen/motion"), do: true

  def topic?(_, _), do: false
end
