defmodule BVS.Negativation.ReturnCode do
  use Ecto.Schema
  import Ecto.Changeset

  schema "return_codes" do
    field :code, :string
    field :description, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(return_code, attrs) do
    return_code
    |> cast(attrs, [:code, :description])
    |> validate_required([:code, :description])
    |> unique_constraint(:code)
  end
end
