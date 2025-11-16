defmodule HomeAuto.Ticker do
  @moduledoc false

  require Logger

  def tick() do
    datetime = DateTime.now!("America/Denver")
    datetime = %{datetime | second: 0, microsecond: {0, 0}}

    Logger.debug("Ticking at #{datetime}")
    Phoenix.PubSub.broadcast(HomeAuto.PubSub, "ticker", {:tick, datetime})
  end

  def daylight_time(datetime) do
    time = DateTime.to_time(datetime)
    dst_flag = if datetime.std_offset == 1, do: :dst, else: :std

    {dst_flag, time}
  end
end
