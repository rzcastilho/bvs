defmodule BVS.Repo.Migrations.CreateOcurrenceTypes do
  use Ecto.Migration

  def change do
    create table(:ocurrence_types) do
      add :code, :string
      add :description, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:ocurrence_types, [:code])
  end
end
