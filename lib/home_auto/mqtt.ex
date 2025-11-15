defmodule HomeAuto.MQTT do
  @moduledoc false

  use GenServer
  alias Phoenix.PubSub

  def start_link([]) do
    GenServer.start_link(__MODULE__, [])
  end

  def init([]) do
    emqtt_opts = Application.get_env(:home_auto, :emqtt)

    PubSub.subscribe(HomeAuto.PubSub, "mqtt:publish")

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

    PubSub.broadcast(HomeAuto.PubSub, "mqtt:all", {:mqtt, topic, payload})
    PubSub.broadcast(HomeAuto.PubSub, "mqtt:" <> topic, {:mqtt, payload})

    {:noreply, state}
  end

  def handle_info({:publish, topic, payload}, state), do: publish(state, topic, payload)
  def handle_cast({:publish, topic, payload}, state), do: publish(state, topic, payload)

  def publish(%{pid: pid} = state, topic, payload) do
    payload = :erlang.term_to_binary(payload)
    :emqtt.publish(pid, topic, payload)

    {:noreply, state}
  end

  def publish(topic, payload), do: GenServer.cast(__MODULE__, {:publish, topic, payload})

  alias HomeAuto.Devices

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
