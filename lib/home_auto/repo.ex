defmodule HomeAuto.Repo do
  use Ecto.Repo,
    otp_app: :home_auto,
    adapter: Ecto.Adapters.Postgres
end
