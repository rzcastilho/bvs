defmodule BVS.NegativationFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `BVS.Negativation` context.
  """

  @doc """
  Generate a unique return_code code.
  """
  def unique_return_code_code, do: "some code#{System.unique_integer([:positive])}"

  @doc """
  Generate a return_code.
  """
  def return_code_fixture(attrs \\ %{}) do
    {:ok, return_code} =
      attrs
      |> Enum.into(%{
        code: unique_return_code_code(),
        description: "some description"
      })
      |> BVS.Negativation.create_return_code()

    return_code
  end

  @doc """
  Generate a unique return_file name.
  """
  def unique_return_file_name, do: "some name#{System.unique_integer([:positive])}"

  @doc """
  Generate a return_file.
  """
  def return_file_fixture(attrs \\ %{}) do
    {:ok, return_file} =
      attrs
      |> Enum.into(%{
        name: unique_return_file_name(),
        status: :found,
        notes: "some notes"
      })
      |> BVS.Negativation.create_return_file()

    return_file
  end

  @doc """
  Generate a unique ocurrence_type code.
  """
  def unique_ocurrence_type_code, do: "some code#{System.unique_integer([:positive])}"

  @doc """
  Generate a ocurrence_type.
  """
  def ocurrence_type_fixture(attrs \\ %{}) do
    {:ok, ocurrence_type} =
      attrs
      |> Enum.into(%{
        code: unique_ocurrence_type_code(),
        description: "some description"
      })
      |> BVS.Negativation.create_ocurrence_type()

    ocurrence_type
  end

  @doc """
  Generate a item.
  """
  def item_fixture(attrs \\ %{}) do
    {:ok, item} =
      attrs
      |> Enum.into(%{
        type: :name,
        details: %{},
        document: "some document",
        document_type: :cnpj,
        sequence: 42
      })
      |> BVS.Negativation.create_item()

    item
  end
end
