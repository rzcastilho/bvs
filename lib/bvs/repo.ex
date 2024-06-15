defmodule BVS.Repo do
  use Ecto.Repo,
    otp_app: :bvs,
    adapter: Ecto.Adapters.SQLite3
end
