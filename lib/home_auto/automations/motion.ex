defmodule HomeAuto.Automations.Motion do
  @moduledoc false

  use GenServer
  alias Phoenix.PubSub

  alias HomeAuto.MQTT
  alias HomeAuto.Devices.Motion

  require Logger

  def start_link(params) do
    GenServer.start_link(__MODULE__, params)
  end

  def child_spec(params) do
    %{
      id: "motion:" <> Atom.to_string(Keyword.get(params, :zone)),
      start: {__MODULE__, :start_link, [params]}
    }
  end

  @impl true
  def init(params) do
    PubSub.subscribe(HomeAuto.PubSub, "mqtt:all")

    state =
      Map.new(params)
      |> Map.merge(%{
        states: %{},
        detected: :false,
      })

    {:ok, state}
  end

  @impl true
  def handle_info({:mqtt, topic, %Motion{} = payload}, state) do
    case Enum.any?(state.consumes, &(MQTT.Topic.matches(topic, &1))) do
      true ->
        new_state = handle_event({topic, payload}, state)
        {:noreply, new_state}

      false -> {:noreply, state}
    end
  end

  @impl true
  def handle_info({:mqtt, _, _}, state), do: {:noreply, state}

  def handle_event({topic, %Motion{} = payload}, state) do
    recently = DateTime.shift(DateTime.utc_now(), day: -1)

    motion_states = Map.put(state.states, topic, payload)
    detected =
      Map.values(motion_states)
      |> Enum.filter(&(DateTime.after?(&1.last_seen, recently)))
      |> Enum.any?(&(&1.detected))

    if state.detected != detected do
      Logger.info("Zone:#{state.zone} Motion Detected? #{detected}")

      mqtt_value = if detected, do: "true", else: "false"
      MQTT.publish(state.produces, mqtt_value)
    end

    %{state | detected: detected, states: motion_states}
  end
end
