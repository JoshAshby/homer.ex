defmodule HomeAuto.Automations.Occupancy do
  @moduledoc false

  use GenServer
  alias Phoenix.PubSub
  alias HomeAuto.Devices.Motion

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
    PubSub.subscribe(HomeAuto.PubSub, "mqtt:all")

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
    state = if Kernel.apply(state.topic?, [topic]) do
      motion_changed(state, topic, payload)
    else
      state
    end

    {:noreply, state}
  end

  @impl true
  def handle_info({:mqtt, _, _}, state), do: {:noreply, state}

  def handle_info(:clear, state), do: {:noreply, %{state | detected: false}}

  def motion_changed(state, topic, %Motion{} = payload) do
    recently = DateTime.shift(DateTime.utc_now(), day: -1)

    motion_states = Map.put(state.states, topic, payload)
    detected =
      Map.values(motion_states)
      |> Enum.filter(&(DateTime.after?(&1.last_seen, recently)))
      |> Enum.any?(&(&1.detected))

    Logger.info("Zone:#{state.zone} Occupancy Detected? #{detected}")

    if state.detected do
      if state.timer do
        Process.cancel_timer(state.timer)
      end

      timer = nil
    else
      timer = Process.send_after(self(), :clear, state.timeout * 60 * 1000)
    end

    %{state | detected: detected, states: motion_states}
  end
end
