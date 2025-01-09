defmodule BVS.Negativation do
  @moduledoc """
  The Negativation context.
  """

  import Ecto.Query, warn: false
  alias BVS.Repo

  alias BVS.Negativation.ReturnCode

  @doc """
  Returns the list of return_codes.

  ## Examples

      iex> list_return_codes()
      [%ReturnCode{}, ...]

  """
  def list_return_codes do
    Repo.all(ReturnCode)
  end

  @doc """
  Gets a single return_code.

  Raises `Ecto.NoResultsError` if the Return code does not exist.

  ## Examples

      iex> get_return_code!(123)
      %ReturnCode{}

      iex> get_return_code!(456)
      ** (Ecto.NoResultsError)

  """
  def get_return_code!(id), do: Repo.get!(ReturnCode, id)

  def get_return_code_by_code(code) do
    ReturnCode
    |> where([rc], rc.code == ^code)
    |> Repo.one()
  end

  @doc """
  Creates a return_code.

  ## Examples

      iex> create_return_code(%{field: value})
      {:ok, %ReturnCode{}}

      iex> create_return_code(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_return_code(attrs \\ %{}) do
    %ReturnCode{}
    |> ReturnCode.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a return_code.

  ## Examples

      iex> update_return_code(return_code, %{field: new_value})
      {:ok, %ReturnCode{}}

      iex> update_return_code(return_code, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_return_code(%ReturnCode{} = return_code, attrs) do
    return_code
    |> ReturnCode.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a return_code.

  ## Examples

      iex> delete_return_code(return_code)
      {:ok, %ReturnCode{}}

      iex> delete_return_code(return_code)
      {:error, %Ecto.Changeset{}}

  """
  def delete_return_code(%ReturnCode{} = return_code) do
    Repo.delete(return_code)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking return_code changes.

  ## Examples

      iex> change_return_code(return_code)
      %Ecto.Changeset{data: %ReturnCode{}}

  """
  def change_return_code(%ReturnCode{} = return_code, attrs \\ %{}) do
    ReturnCode.changeset(return_code, attrs)
  end

  alias BVS.Negativation.ReturnFile
  alias BVS.Negativation.Item

  def preload_error_items() do
    from i in Item,
      join: rc in ReturnCode,
      on: i.return_code_id == rc.id and rc.code != "00"
  end

  @doc """
  Returns the list of return_files.

  ## Examples

      iex> list_return_files()
      [%ReturnFile{}, ...]

  """
  def list_return_files do
    ReturnFile
    |> preload(items: ^preload_error_items())
    |> order_by([rf], desc: rf.name)
    |> Repo.all()
  end

  @doc """
  Gets a single return_file.

  Raises `Ecto.NoResultsError` if the Return file does not exist.

  ## Examples

      iex> get_return_file!(123)
      %ReturnFile{}

      iex> get_return_file!(456)
      ** (Ecto.NoResultsError)

  """
  def get_return_file!(id) do
    ReturnFile
    |> preload([:items])
    |> Repo.get!(id)
  end

  def get_return_file_by_name(name) do
    ReturnFile
    |> where([rf], rf.name == ^name)
    |> Repo.one()
  end

  @doc """
  Creates a return_file.

  ## Examples

      iex> create_return_file(%{field: value})
      {:ok, %ReturnFile{}}

      iex> create_return_file(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_return_file(attrs \\ %{}) do
    with {:ok, return_file} <-
           %ReturnFile{}
           |> ReturnFile.changeset(attrs)
           |> Repo.insert() do
      {:ok, Repo.preload(return_file, items: preload_error_items())}
    end
  end

  @doc """
  Updates a return_file.

  ## Examples

      iex> update_return_file(return_file, %{field: new_value})
      {:ok, %ReturnFile{}}

      iex> update_return_file(return_file, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_return_file(%ReturnFile{} = return_file, attrs) do
    with {:ok, return_file} <-
           return_file
           |> ReturnFile.changeset(attrs)
           |> Repo.update() do
      {
        :ok,
        return_file
        |> Repo.reload()
        |> Repo.preload(items: preload_error_items())
      }
    end
  end

  @doc """
  Deletes a return_file.

  ## Examples

      iex> delete_return_file(return_file)
      {:ok, %ReturnFile{}}

      iex> delete_return_file(return_file)
      {:error, %Ecto.Changeset{}}

  """
  def delete_return_file(%ReturnFile{} = return_file) do
    Repo.delete(return_file)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking return_file changes.

  ## Examples

      iex> change_return_file(return_file)
      %Ecto.Changeset{data: %ReturnFile{}}

  """
  def change_return_file(%ReturnFile{} = return_file, attrs \\ %{}) do
    ReturnFile.changeset(return_file, attrs)
  end

  def update_return_file_status_by_id(id, status) do
    id
    |> get_return_file!()
    |> update_return_file(%{status: status})
  end

  def update_return_file_status_by_name(name, status) do
    name
    |> get_return_file_by_name()
    |> update_return_file(%{status: status})
  end

  alias BVS.Negativation.OcurrenceType

  @doc """
  Returns the list of ocurrence_types.

  ## Examples

      iex> list_ocurrence_types()
      [%OcurrenceType{}, ...]

  """
  def list_ocurrence_types do
    Repo.all(OcurrenceType)
  end

  @doc """
  Gets a single ocurrence_type.

  Raises `Ecto.NoResultsError` if the Ocurrence type does not exist.

  ## Examples

      iex> get_ocurrence_type!(123)
      %OcurrenceType{}

      iex> get_ocurrence_type!(456)
      ** (Ecto.NoResultsError)

  """
  def get_ocurrence_type!(id), do: Repo.get!(OcurrenceType, id)

  @doc """
  Creates a ocurrence_type.

  ## Examples

      iex> create_ocurrence_type(%{field: value})
      {:ok, %OcurrenceType{}}

      iex> create_ocurrence_type(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_ocurrence_type(attrs \\ %{}) do
    %OcurrenceType{}
    |> OcurrenceType.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a ocurrence_type.

  ## Examples

      iex> update_ocurrence_type(ocurrence_type, %{field: new_value})
      {:ok, %OcurrenceType{}}

      iex> update_ocurrence_type(ocurrence_type, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_ocurrence_type(%OcurrenceType{} = ocurrence_type, attrs) do
    ocurrence_type
    |> OcurrenceType.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a ocurrence_type.

  ## Examples

      iex> delete_ocurrence_type(ocurrence_type)
      {:ok, %OcurrenceType{}}

      iex> delete_ocurrence_type(ocurrence_type)
      {:error, %Ecto.Changeset{}}

  """
  def delete_ocurrence_type(%OcurrenceType{} = ocurrence_type) do
    Repo.delete(ocurrence_type)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking ocurrence_type changes.

  ## Examples

      iex> change_ocurrence_type(ocurrence_type)
      %Ecto.Changeset{data: %OcurrenceType{}}

  """
  def change_ocurrence_type(%OcurrenceType{} = ocurrence_type, attrs \\ %{}) do
    OcurrenceType.changeset(ocurrence_type, attrs)
  end

  @doc """
  Returns the list of items.

  ## Examples

      iex> list_items()
      [%Item{}, ...]

  """
  def list_items do
    Item
    |> preload(:return_code)
    |> order_by([i], asc: i.return_file_id, asc: i.sequence)
    |> Repo.all()
  end

  def list_items_with_errors_by_return_file_id(return_file_id) do
    Item
    |> join(:inner, [i], rc in ReturnCode, on: i.return_code_id == rc.id and rc.code != "00")
    |> where([i], i.return_file_id == ^return_file_id)
    |> preload(:return_code)
    |> order_by([i], asc: i.return_file_id, asc: i.sequence)
    |> Repo.all()
  end

  @doc """
  Gets a single item.

  Raises `Ecto.NoResultsError` if the Item does not exist.

  ## Examples

      iex> get_item!(123)
      %Item{}

      iex> get_item!(456)
      ** (Ecto.NoResultsError)

  """
  def get_item!(id) do
    Item
    |> preload(:return_code)
    |> Repo.get!(id)
  end

  @doc """
  Creates a item.

  ## Examples

      iex> create_item(%{field: value})
      {:ok, %Item{}}

      iex> create_item(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_item(attrs \\ %{}) do
    with {:ok, item} <-
           %Item{}
           |> Item.changeset(attrs)
           |> Repo.insert() do
      {:ok, Repo.preload(item, [:return_code])}
    end
  end

  @doc """
  Updates a item.

  ## Examples

      iex> update_item(item, %{field: new_value})
      {:ok, %Item{}}

      iex> update_item(item, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_item(%Item{} = item, attrs) do
    with {:ok, item} <-
           item
           |> Item.changeset(attrs)
           |> Repo.update() do
      {:ok, Repo.preload(item, [:return_code])}
    end
  end

  @doc """
  Deletes a item.

  ## Examples

      iex> delete_item(item)
      {:ok, %Item{}}

      iex> delete_item(item)
      {:error, %Ecto.Changeset{}}

  """
  def delete_item(%Item{} = item) do
    Repo.delete(item)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking item changes.

  ## Examples

      iex> change_item(item)
      %Ecto.Changeset{data: %Item{}}

  """
  def change_item(%Item{} = item, attrs \\ %{}) do
    Item.changeset(item, attrs)
  end
end
