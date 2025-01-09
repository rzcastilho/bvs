defmodule BVS.Negativation.Item do
  use Ecto.Schema
  import Ecto.Changeset

  alias BVS.Negativation.ReturnCode

  schema "items" do
    field :type, Ecto.Enum, values: [:name, :address, :ocurrence]

    field :document_type, Ecto.Enum,
      values: [
        :cnpj,
        :nire,
        :cpf,
        :rg,
        :cp,
        :te,
        :cr,
        :re,
        :crm,
        :oab,
        :cie,
        :ima,
        :ime,
        :imm,
        :cnh,
        :cf,
        :crc,
        :pas,
        :rne
      ]

    field :document, :string
    field :sequence, :integer
    field :details, :map
    field :return_file_id, :id

    belongs_to :return_code, ReturnCode

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [
      :return_file_id,
      :return_code_id,
      :type,
      :document_type,
      :document,
      :sequence,
      :details
    ])
    |> validate_required([
      :return_file_id,
      :return_code_id,
      :type,
      :document_type,
      :document,
      :sequence
    ])
    |> foreign_key_constraint(:return_file_id)
    |> foreign_key_constraint(:return_code_id)
  end
end
