defmodule AirAlert.Repo do
  use Ecto.Repo,
    otp_app: :air_alert,
    adapter: Ecto.Adapters.Postgres
end
