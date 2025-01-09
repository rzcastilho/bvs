defmodule BVSWeb.ReturnFileLiveTest do
  use BVSWeb.ConnCase

  import Phoenix.LiveViewTest
  import BVS.NegativationFixtures

  @create_attrs %{name: "some name", status: :found, notes: "some notes"}
  @update_attrs %{
    name: "some updated name",
    status: :downloaded,
    notes: "some updated notes"
  }
  @invalid_attrs %{name: nil, status: :found, notes: nil}

  defp create_return_file(_) do
    return_file =
      return_file_fixture()
      |> BVS.Repo.preload([:items])

    %{return_file: return_file}
  end

  describe "Index" do
    setup [:create_return_file]

    test "lists all return_files", %{conn: conn, return_file: return_file} do
      {:ok, _index_live, html} = live(conn, ~p"/return_files")

      assert html =~ "Listing Return files"
      assert html =~ return_file.name
    end

    test "saves new return_file", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/return_files")

      assert index_live |> element("a", "New Return file") |> render_click() =~
               "New Return file"

      assert_patch(index_live, ~p"/return_files/new")

      assert index_live
             |> form("#return_file-form", return_file: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#return_file-form", return_file: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/return_files")

      html = render(index_live)
      assert html =~ "Return file created successfully"
      assert html =~ "some name"
    end

    test "updates return_file in listing", %{conn: conn, return_file: return_file} do
      {:ok, index_live, _html} = live(conn, ~p"/return_files")

      assert index_live |> element("#return_files-#{return_file.id} a", "Edit") |> render_click() =~
               "Edit Return file"

      assert_patch(index_live, ~p"/return_files/#{return_file}/edit")

      assert index_live
             |> form("#return_file-form", return_file: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#return_file-form", return_file: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/return_files")

      html = render(index_live)
      assert html =~ "Return file updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes return_file in listing", %{conn: conn, return_file: return_file} do
      {:ok, index_live, _html} = live(conn, ~p"/return_files")

      assert index_live
             |> element("#return_files-#{return_file.id} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#return_files-#{return_file.id}")
    end
  end

  describe "Show" do
    setup [:create_return_file]

    test "displays return_file", %{conn: conn, return_file: return_file} do
      {:ok, _show_live, html} = live(conn, ~p"/return_files/#{return_file}")

      assert html =~ "Show Return file"
      assert html =~ return_file.name
    end

    test "updates return_file within modal", %{conn: conn, return_file: return_file} do
      {:ok, show_live, _html} = live(conn, ~p"/return_files/#{return_file}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Return file"

      assert_patch(show_live, ~p"/return_files/#{return_file}/show/edit")

      assert show_live
             |> form("#return_file-form", return_file: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#return_file-form", return_file: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/return_files/#{return_file}")

      html = render(show_live)
      assert html =~ "Return file updated successfully"
      assert html =~ "some updated name"
    end
  end
end
