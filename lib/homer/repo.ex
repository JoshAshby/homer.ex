defmodule Homer.Repo do
  use Ecto.Repo,
    otp_app: :homer,
    adapter: Ecto.Adapters.SQLite3
end
