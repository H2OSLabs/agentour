defmodule Agentour.Repo do
  use Ecto.Repo,
    otp_app: :agentour,
    adapter: Ecto.Adapters.Postgres
end
