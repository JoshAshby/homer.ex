defmodule HomeAuto.Devices.Motion do
  @moduledoc false

  defstruct detected: false, last_seen: nil

  def from_occupancy_sensor(payload) do
    event = Jason.decode!(payload)

    %__MODULE__{
      detected: Map.get(event, "occupancy"),
      last_seen: DateTime.from_unix!(Map.get(event, "last_seen"), :millisecond)
    }
  end

  def from_boolean_sensor(payload) do
    %__MODULE__{
      detected: payload == "true",
      last_seen: DateTime.utc_now()
    }
  end

  def to_mqtt(%__MODULE__{} = payload) do
    if payload.detected, do: "true", else: "false"
  end
end
