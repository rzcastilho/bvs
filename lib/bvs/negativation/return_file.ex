defmodule BVS.Negativation.ReturnFile do
  use Ecto.Schema
  import Ecto.Changeset

  alias BVS.Negativation.Item

  schema "return_files" do
    field :name, :string

    field :status, Ecto.Enum,
      values: [:found, :downloaded, :processed, :reviewed, :pending, :error],
      default: :found

    field :notes

    has_many :items, Item

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(return_file, attrs) do
    return_file
    |> cast(attrs, [:name, :status, :notes])
    |> validate_required([:name, :status])
    |> unique_constraint(:name)
  end
end
