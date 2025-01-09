defmodule BVS.NegativationTest do
  use BVS.DataCase

  alias BVS.Negativation

  describe "return_codes" do
    alias BVS.Negativation.ReturnCode

    import BVS.NegativationFixtures

    @invalid_attrs %{code: nil, description: nil}

    test "list_return_codes/0 returns all return_codes" do
      return_code = return_code_fixture()
      assert Negativation.list_return_codes() == [return_code]
    end

    test "get_return_code!/1 returns the return_code with given id" do
      return_code = return_code_fixture()
      assert Negativation.get_return_code!(return_code.id) == return_code
    end

    test "create_return_code/1 with valid data creates a return_code" do
      valid_attrs = %{code: "some code", description: "some description"}

      assert {:ok, %ReturnCode{} = return_code} = Negativation.create_return_code(valid_attrs)
      assert return_code.code == "some code"
      assert return_code.description == "some description"
    end

    test "create_return_code/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Negativation.create_return_code(@invalid_attrs)
    end

    test "update_return_code/2 with valid data updates the return_code" do
      return_code = return_code_fixture()
      update_attrs = %{code: "some updated code", description: "some updated description"}

      assert {:ok, %ReturnCode{} = return_code} =
               Negativation.update_return_code(return_code, update_attrs)

      assert return_code.code == "some updated code"
      assert return_code.description == "some updated description"
    end

    test "update_return_code/2 with invalid data returns error changeset" do
      return_code = return_code_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Negativation.update_return_code(return_code, @invalid_attrs)

      assert return_code == Negativation.get_return_code!(return_code.id)
    end

    test "delete_return_code/1 deletes the return_code" do
      return_code = return_code_fixture()
      assert {:ok, %ReturnCode{}} = Negativation.delete_return_code(return_code)
      assert_raise Ecto.NoResultsError, fn -> Negativation.get_return_code!(return_code.id) end
    end

    test "change_return_code/1 returns a return_code changeset" do
      return_code = return_code_fixture()
      assert %Ecto.Changeset{} = Negativation.change_return_code(return_code)
    end
  end

  describe "return_files" do
    alias BVS.Negativation.ReturnFile

    import BVS.NegativationFixtures

    @invalid_attrs %{name: nil, status: nil, notes: nil}

    test "list_return_files/0 returns all return_files" do
      return_file =
        return_file_fixture()
        |> BVS.Repo.preload([:items])

      assert Negativation.list_return_files() == [return_file]
    end

    test "get_return_file!/1 returns the return_file with given id" do
      return_file = return_file_fixture()
      assert Negativation.get_return_file!(return_file.id) == return_file
    end

    test "create_return_file/1 with valid data creates a return_file" do
      valid_attrs = %{
        name: "some name",
        status: :found,
        notes: "some notes"
      }

      assert {:ok, %ReturnFile{} = return_file} = Negativation.create_return_file(valid_attrs)
      assert return_file.name == "some name"
      assert return_file.status == :found
      assert return_file.notes == "some notes"
    end

    test "create_return_file/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Negativation.create_return_file(@invalid_attrs)
    end

    test "update_return_file/2 with valid data updates the return_file" do
      return_file = return_file_fixture()

      update_attrs = %{
        name: "some updated name",
        status: :downloaded,
        notes: "some updated notes"
      }

      assert {:ok, %ReturnFile{} = return_file} =
               Negativation.update_return_file(return_file, update_attrs)

      assert return_file.name == "some updated name"
      assert return_file.status == :downloaded
      assert return_file.notes == "some updated notes"
    end

    test "update_return_file/2 with invalid data returns error changeset" do
      return_file = return_file_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Negativation.update_return_file(return_file, @invalid_attrs)

      assert return_file == Negativation.get_return_file!(return_file.id)
    end

    test "delete_return_file/1 deletes the return_file" do
      return_file = return_file_fixture()
      assert {:ok, %ReturnFile{}} = Negativation.delete_return_file(return_file)
      assert_raise Ecto.NoResultsError, fn -> Negativation.get_return_file!(return_file.id) end
    end

    test "change_return_file/1 returns a return_file changeset" do
      return_file = return_file_fixture()
      assert %Ecto.Changeset{} = Negativation.change_return_file(return_file)
    end
  end

  describe "ocurrence_types" do
    alias BVS.Negativation.OcurrenceType

    import BVS.NegativationFixtures

    @invalid_attrs %{code: nil, description: nil}

    test "list_ocurrence_types/0 returns all ocurrence_types" do
      ocurrence_type = ocurrence_type_fixture()
      assert Negativation.list_ocurrence_types() == [ocurrence_type]
    end

    test "get_ocurrence_type!/1 returns the ocurrence_type with given id" do
      ocurrence_type = ocurrence_type_fixture()
      assert Negativation.get_ocurrence_type!(ocurrence_type.id) == ocurrence_type
    end

    test "create_ocurrence_type/1 with valid data creates a ocurrence_type" do
      valid_attrs = %{code: "some code", description: "some description"}

      assert {:ok, %OcurrenceType{} = ocurrence_type} =
               Negativation.create_ocurrence_type(valid_attrs)

      assert ocurrence_type.code == "some code"
      assert ocurrence_type.description == "some description"
    end

    test "create_ocurrence_type/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Negativation.create_ocurrence_type(@invalid_attrs)
    end

    test "update_ocurrence_type/2 with valid data updates the ocurrence_type" do
      ocurrence_type = ocurrence_type_fixture()
      update_attrs = %{code: "some updated code", description: "some updated description"}

      assert {:ok, %OcurrenceType{} = ocurrence_type} =
               Negativation.update_ocurrence_type(ocurrence_type, update_attrs)

      assert ocurrence_type.code == "some updated code"
      assert ocurrence_type.description == "some updated description"
    end

    test "update_ocurrence_type/2 with invalid data returns error changeset" do
      ocurrence_type = ocurrence_type_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Negativation.update_ocurrence_type(ocurrence_type, @invalid_attrs)

      assert ocurrence_type == Negativation.get_ocurrence_type!(ocurrence_type.id)
    end

    test "delete_ocurrence_type/1 deletes the ocurrence_type" do
      ocurrence_type = ocurrence_type_fixture()
      assert {:ok, %OcurrenceType{}} = Negativation.delete_ocurrence_type(ocurrence_type)

      assert_raise Ecto.NoResultsError, fn ->
        Negativation.get_ocurrence_type!(ocurrence_type.id)
      end
    end

    test "change_ocurrence_type/1 returns a ocurrence_type changeset" do
      ocurrence_type = ocurrence_type_fixture()
      assert %Ecto.Changeset{} = Negativation.change_ocurrence_type(ocurrence_type)
    end
  end

  describe "items" do
    alias BVS.Negativation.Item

    import BVS.NegativationFixtures

    @invalid_attrs %{type: nil, document_type: nil, document: nil, sequence: nil, details: nil}

    test "list_items/0 returns all items" do
      return_file = return_file_fixture()
      return_code = return_code_fixture()

      item =
        %{return_file_id: return_file.id, return_code_id: return_code.id}
        |> item_fixture()
        |> BVS.Repo.preload([:return_code])

      assert Negativation.list_items() == [item]
    end

    test "get_item!/1 returns the item with given id" do
      return_file = return_file_fixture()
      return_code = return_code_fixture()

      item =
        %{return_file_id: return_file.id, return_code_id: return_code.id}
        |> item_fixture()
        |> BVS.Repo.preload([:return_code])

      assert Negativation.get_item!(item.id) == item
    end

    test "create_item/1 with valid data creates a item" do
      return_file = return_file_fixture()
      return_code = return_code_fixture()

      valid_attrs = %{
        type: :address,
        document_type: :cnpj,
        document: "some document",
        sequence: 42,
        details: %{},
        return_file_id: return_file.id,
        return_code_id: return_code.id
      }

      assert {:ok, %Item{} = item} = Negativation.create_item(valid_attrs)
      assert item.type == :address
      assert item.document_type == :cnpj
      assert item.document == "some document"
      assert item.sequence == 42
      assert item.details == %{}
    end

    test "create_item/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Negativation.create_item(@invalid_attrs)
    end

    test "update_item/2 with valid data updates the item" do
      return_file = return_file_fixture()
      return_code = return_code_fixture()
      item = item_fixture(%{return_file_id: return_file.id, return_code_id: return_code.id})

      update_attrs = %{
        type: :ocurrence,
        document_type: :nire,
        document: "some updated document",
        sequence: 43,
        details: %{}
      }

      assert {:ok, %Item{} = item} = Negativation.update_item(item, update_attrs)
      assert item.type == :ocurrence
      assert item.document_type == :nire
      assert item.document == "some updated document"
      assert item.sequence == 43
      assert item.details == %{}
    end

    test "update_item/2 with invalid data returns error changeset" do
      return_file = return_file_fixture()
      return_code = return_code_fixture()

      item =
        %{return_file_id: return_file.id, return_code_id: return_code.id}
        |> item_fixture()
        |> BVS.Repo.preload([:return_code])

      assert {:error, %Ecto.Changeset{}} = Negativation.update_item(item, @invalid_attrs)
      assert item == Negativation.get_item!(item.id)
    end

    test "delete_item/1 deletes the item" do
      return_file = return_file_fixture()
      return_code = return_code_fixture()
      item = item_fixture(%{return_file_id: return_file.id, return_code_id: return_code.id})
      assert {:ok, %Item{}} = Negativation.delete_item(item)
      assert_raise Ecto.NoResultsError, fn -> Negativation.get_item!(item.id) end
    end

    test "change_item/1 returns a item changeset" do
      return_file = return_file_fixture()
      return_code = return_code_fixture()
      item = item_fixture(%{return_file_id: return_file.id, return_code_id: return_code.id})
      assert %Ecto.Changeset{} = Negativation.change_item(item)
    end
  end
end
