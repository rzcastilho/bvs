defmodule BVS.Repo.Migrations.CreateReturnFiles do
  use Ecto.Migration

  def change do
    create table(:return_files) do
      add :name, :string
      add :status, :string, default: "found"
      add :notes, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:return_files, [:name])
  end
end
