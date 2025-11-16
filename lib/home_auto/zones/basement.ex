defmodule HomeAuto.Zones.Basement do
  @moduledoc false

  def topic?(:motion, "zigbee/basement/motion/" <> _), do: true
  def topic?(:motion, "zigbee/basement/presence/" <> _), do: true
  def topic?(:motion, "homekit/house/basement/aqara-fp2-1/set/state"), do: true

  def topic?(:occupancy, "homekit/house/zones/basement/motion"), do: true

  def topic?(_, _), do: false
end
