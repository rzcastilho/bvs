defmodule BVS.Repo.Migrations.CreateItems do
  use Ecto.Migration

  def change do
    create table(:items) do
      add :type, :string
      add :document_type, :string
      add :document, :string
      add :sequence, :integer
      add :details, :map
      add :return_file_id, references(:return_files, on_delete: :delete_all)
      add :return_code_id, references(:return_codes, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:items, [:return_file_id])
    create index(:items, [:return_code_id])
  end
end
