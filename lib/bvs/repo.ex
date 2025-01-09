defmodule BVS.Repo do
  use Ecto.Repo,
    otp_app: :bvs,
    adapter: Ecto.Adapters.SQLite3

  def init(_type, config) do
    database = Keyword.get(config, :database)

    case database do
      nil ->
        {:ok, Keyword.put(config, :database, DoIt.Commfig.get(["repo", "database"]))}

      _database ->
        {:ok, config}
    end
  end
end
