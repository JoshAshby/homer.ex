defmodule HomeAuto.Schedules.Morning do
  @moduledoc false

  use GenServer

  def start_link(params) do
    GenServer.start_link(__MODULE__, params)
  end

  @impl true
  def init(params) do
    state = %{}

    {:ok, state}
  end

  @impl true
  def handle_info(msg, state) do
    {:noreply, state}

    #{:ok, sequence_pid} =
      #Sequence.run(
        #[
          #{450, {}],
          #{450, {}],
          #{450, {}],
          #{450, {}],
        #]
      #)

    #new_state = %{state | sequence_pid: sequence_pid}
    #{:noreply, new_state}
  end
end
