defmodule BVS.Repo.Migrations.CreateReturnCodes do
  use Ecto.Migration

  def change do
    create table(:return_codes) do
      add :code, :string
      add :description, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:return_codes, [:code])
  end
end
