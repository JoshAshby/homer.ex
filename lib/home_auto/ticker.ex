defmodule HomeAuto.Ticker do
  @moduledoc false

  def tick() do
    Phoenix.PubSub.broadcast(HomeAuto.PubSub, "ticker", {:tick, %{}})
  end

  #use GenServer

  #def start_link([]) do
    #GenServer.start_link(__MODULE__, [])
  #end

  #def init([]) do
    #state = %{
      #interval: 1 * 60 * 1000, # Tick on ence every minute
      #timer: nil
    #}

    #{:ok, set_timer(state)}
  #end

  #def handle_info(:tick, state) do
    #{:noreply, set_timer(state)}
  #end

  #defp set_timer(%{ timer: timer, interval: interval } = state) do
    #if timer do
      #Process.cancel_timer(timer)
    #end

    #timer = Process.send_after(self(), :tick, interval)
    #%{state | timer: timer}
  #end
end
