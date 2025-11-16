defmodule HomeAuto.Sequence do
  @moduledoc false

  use GenServer
  alias Phoenix.PubSub

  def run(steps), do: start_link(steps: steps)

  def start_link(params) do
    GenServer.start_link(__MODULE__, params)
  end

  @impl true
  def init(params) do

    state = Map.new(params)

    {:ok, state, {:continue, :kickoff}}
  end

  @impl true
  def handle_continue(:kickoff, state), do: step(state)

  @impl true
  def handle_info(:step, state), do: step(state)

  def step(state) do
    case state.steps do
      [] ->
        {:stop, :normal, state}

      [{duration, opts} = step | rest] ->
        {mod, fun, args} = opts
        Kernel.apply(mod, fun, args)

        timer = Process.send_after(self(), :step, duration)
        {:noreply, Map.merge(state, %{steps: rest, timer: timer, last: step})}
    end
  end
end
