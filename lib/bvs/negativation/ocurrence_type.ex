defmodule BVS.Negativation.OcurrenceType do
  use Ecto.Schema
  import Ecto.Changeset

  schema "ocurrence_types" do
    field :code, :string
    field :description, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(ocurrence_type, attrs) do
    ocurrence_type
    |> cast(attrs, [:code, :description])
    |> validate_required([:code, :description])
    |> unique_constraint(:code)
  end
end
