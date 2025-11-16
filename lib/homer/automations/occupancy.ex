defmodule Homer.Automations.Occupancy do
  @moduledoc false

  use GenServer
  alias Phoenix.PubSub

  alias Homer.MQTT
  alias Homer.Devices.Motion

  require Logger

  def start_link(params) do
    GenServer.start_link(__MODULE__, params)
  end

  def child_spec(params) do
    %{
      id: "occupancy:" <> Atom.to_string(Keyword.get(params, :zone)),
      start: {__MODULE__, :start_link, [params]}
    }
  end

  @impl true
  def init(params) do
    PubSub.subscribe(Homer.PubSub, "mqtt:all")

    state =
      Map.new(params)
      |> Map.merge(%{
        states: %{},
        detected: :false,
        timer: nil,
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

  @impl true
  def handle_info(:clear, state) do
    Logger.info("Zone:#{state.zone} Occupancy Detected? false")
    MQTT.publish(state.produces, "false")

    {:noreply, %{state | detected: false}}
  end

  def handle_event({topic, %Motion{} = payload}, state) do
    recently = DateTime.shift(DateTime.utc_now(), day: -1)

    motion_states = Map.put(state.states, topic, payload)
    detected =
      Map.values(motion_states)
      |> Enum.filter(&(DateTime.after?(&1.last_seen, recently)))
      |> Enum.any?(&(&1.detected))

    if detected do
      if state.timer do
        Process.cancel_timer(state.timer)
      end

      timer = nil

      Logger.info("Zone:#{state.zone} Occupancy Detected? true")
      MQTT.publish(state.produces, "true")
    else
      timer = Process.send_after(self(), :clear, state.timeout * 60 * 1000)
    end

    %{state | detected: detected, states: motion_states}
  end
end
