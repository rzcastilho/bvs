defmodule BVSWeb.OcurrenceTypeLiveTest do
  use BVSWeb.ConnCase

  import Phoenix.LiveViewTest
  import BVS.NegativationFixtures

  @create_attrs %{code: "some code", description: "some description"}
  @update_attrs %{code: "some updated code", description: "some updated description"}
  @invalid_attrs %{code: nil, description: nil}

  defp create_ocurrence_type(_) do
    ocurrence_type = ocurrence_type_fixture()
    %{ocurrence_type: ocurrence_type}
  end

  describe "Index" do
    setup [:create_ocurrence_type]

    test "lists all ocurrence_types", %{conn: conn, ocurrence_type: ocurrence_type} do
      {:ok, _index_live, html} = live(conn, ~p"/ocurrence_types")

      assert html =~ "Listing Ocurrence types"
      assert html =~ ocurrence_type.code
    end

    test "saves new ocurrence_type", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/ocurrence_types")

      assert index_live |> element("a", "New Ocurrence type") |> render_click() =~
               "New Ocurrence type"

      assert_patch(index_live, ~p"/ocurrence_types/new")

      assert index_live
             |> form("#ocurrence_type-form", ocurrence_type: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#ocurrence_type-form", ocurrence_type: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/ocurrence_types")

      html = render(index_live)
      assert html =~ "Ocurrence type created successfully"
      assert html =~ "some code"
    end

    test "updates ocurrence_type in listing", %{conn: conn, ocurrence_type: ocurrence_type} do
      {:ok, index_live, _html} = live(conn, ~p"/ocurrence_types")

      assert index_live |> element("#ocurrence_types-#{ocurrence_type.id} a", "Edit") |> render_click() =~
               "Edit Ocurrence type"

      assert_patch(index_live, ~p"/ocurrence_types/#{ocurrence_type}/edit")

      assert index_live
             |> form("#ocurrence_type-form", ocurrence_type: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#ocurrence_type-form", ocurrence_type: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/ocurrence_types")

      html = render(index_live)
      assert html =~ "Ocurrence type updated successfully"
      assert html =~ "some updated code"
    end

    test "deletes ocurrence_type in listing", %{conn: conn, ocurrence_type: ocurrence_type} do
      {:ok, index_live, _html} = live(conn, ~p"/ocurrence_types")

      assert index_live |> element("#ocurrence_types-#{ocurrence_type.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#ocurrence_types-#{ocurrence_type.id}")
    end
  end

  describe "Show" do
    setup [:create_ocurrence_type]

    test "displays ocurrence_type", %{conn: conn, ocurrence_type: ocurrence_type} do
      {:ok, _show_live, html} = live(conn, ~p"/ocurrence_types/#{ocurrence_type}")

      assert html =~ "Show Ocurrence type"
      assert html =~ ocurrence_type.code
    end

    test "updates ocurrence_type within modal", %{conn: conn, ocurrence_type: ocurrence_type} do
      {:ok, show_live, _html} = live(conn, ~p"/ocurrence_types/#{ocurrence_type}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Ocurrence type"

      assert_patch(show_live, ~p"/ocurrence_types/#{ocurrence_type}/show/edit")

      assert show_live
             |> form("#ocurrence_type-form", ocurrence_type: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#ocurrence_type-form", ocurrence_type: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/ocurrence_types/#{ocurrence_type}")

      html = render(show_live)
      assert html =~ "Ocurrence type updated successfully"
      assert html =~ "some updated code"
    end
  end
end
