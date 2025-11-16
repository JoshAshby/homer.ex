defmodule Homer.MQTT do
  @moduledoc false

  use GenServer
  alias Phoenix.PubSub

  require Logger

  def start_link([]) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    emqtt_opts = Application.get_env(:homer, :emqtt)

    {:ok, pid} = :emqtt.start_link(emqtt_opts)
    state = %{pid: pid}

    {:ok, state, {:continue, :start_emqtt}}
  end

  def handle_continue(:start_emqtt, %{pid: pid} = state) do
    {:ok, _} = :emqtt.connect(pid)
    {:ok, _, _} = :emqtt.subscribe(pid, {"#", 1})

    {:noreply, state}
  end

  def handle_info({:publish, publish}, state) do
    %{topic: topic, payload: payload} = publish
    {:ok, topic, payload} = normalize(topic, payload)

    PubSub.broadcast(Homer.PubSub, "mqtt:all", {:mqtt, topic, payload})
    PubSub.broadcast(Homer.PubSub, "mqtt:" <> topic, {:mqtt, payload})

    {:noreply, state}
  end

  def handle_cast({:publish_outbound, topic, payload}, state), do: handle_publish({topic, payload}, state)

  def handle_publish({topic, payload}, %{pid: pid} = state) do
    res = :emqtt.publish(pid, topic, payload)
    Logger.info("Published to #{topic} with #{payload} - #{res}")

    {:noreply, state}
  end

  def publish(topic, payload), do:
    GenServer.cast(__MODULE__, {:publish_outbound, topic, payload})

  alias Homer.Devices

  def normalize("zigbee/basement/motion/" <> _ = topic, payload), do: {:ok, topic, Devices.Motion.from_occupancy_sensor(payload)}
  def normalize("zigbee/basement/presence/" <> _ = topic, payload), do: {:ok, topic, Devices.Motion.from_occupancy_sensor(payload)}
  def normalize("homekit/house/basement/aqara-fp2-1/set/state" = topic, payload), do: {:ok, topic, Devices.Motion.from_boolean_sensor(payload)}
  def normalize("homekit/house/zones/basement/motion" = topic, payload), do: {:ok, topic, Devices.Motion.from_boolean_sensor(payload)}

  def normalize("zigbee/kitchen/motion/" <> _ = topic, payload), do: {:ok, topic, Devices.Motion.from_occupancy_sensor(payload)}
  def normalize("zigbee/kitchen/presence/" <> _ = topic, payload), do: {:ok, topic, Devices.Motion.from_occupancy_sensor(payload)}
  def normalize("homekit/house/zones/kitchen/motion" = topic, payload), do: {:ok, topic, Devices.Motion.from_boolean_sensor(payload)}

  def normalize("zigbee/living-room/motion/" <> _ = topic, payload), do: {:ok, topic, Devices.Motion.from_occupancy_sensor(payload)}
  def normalize("zigbee/living-room/presence/" <> _ = topic, payload), do: {:ok, topic, Devices.Motion.from_occupancy_sensor(payload)}
  def normalize("homekit/house/zones/living-room/motion" = topic, payload), do: {:ok, topic, Devices.Motion.from_boolean_sensor(payload)}

  #def normalize("zigbee/" <> _ <> "/temp/" <> _ = topic, payload), do: {:ok, topic, Devices.Temp.from_temp_sensor(payload)}

  def normalize(topic, payload), do: {:ok, topic, payload}
end
