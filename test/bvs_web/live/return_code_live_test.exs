defmodule BVSWeb.ReturnCodeLiveTest do
  use BVSWeb.ConnCase

  import Phoenix.LiveViewTest
  import BVS.NegativationFixtures

  @create_attrs %{code: "some code", description: "some description"}
  @update_attrs %{code: "some updated code", description: "some updated description"}
  @invalid_attrs %{code: nil, description: nil}

  defp create_return_code(_) do
    return_code = return_code_fixture()
    %{return_code: return_code}
  end

  describe "Index" do
    setup [:create_return_code]

    test "lists all return_codes", %{conn: conn, return_code: return_code} do
      {:ok, _index_live, html} = live(conn, ~p"/return_codes")

      assert html =~ "Listing Return codes"
      assert html =~ return_code.code
    end

    test "saves new return_code", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/return_codes")

      assert index_live |> element("a", "New Return code") |> render_click() =~
               "New Return code"

      assert_patch(index_live, ~p"/return_codes/new")

      assert index_live
             |> form("#return_code-form", return_code: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#return_code-form", return_code: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/return_codes")

      html = render(index_live)
      assert html =~ "Return code created successfully"
      assert html =~ "some code"
    end

    test "updates return_code in listing", %{conn: conn, return_code: return_code} do
      {:ok, index_live, _html} = live(conn, ~p"/return_codes")

      assert index_live |> element("#return_codes-#{return_code.id} a", "Edit") |> render_click() =~
               "Edit Return code"

      assert_patch(index_live, ~p"/return_codes/#{return_code}/edit")

      assert index_live
             |> form("#return_code-form", return_code: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#return_code-form", return_code: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/return_codes")

      html = render(index_live)
      assert html =~ "Return code updated successfully"
      assert html =~ "some updated code"
    end

    test "deletes return_code in listing", %{conn: conn, return_code: return_code} do
      {:ok, index_live, _html} = live(conn, ~p"/return_codes")

      assert index_live |> element("#return_codes-#{return_code.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#return_codes-#{return_code.id}")
    end
  end

  describe "Show" do
    setup [:create_return_code]

    test "displays return_code", %{conn: conn, return_code: return_code} do
      {:ok, _show_live, html} = live(conn, ~p"/return_codes/#{return_code}")

      assert html =~ "Show Return code"
      assert html =~ return_code.code
    end

    test "updates return_code within modal", %{conn: conn, return_code: return_code} do
      {:ok, show_live, _html} = live(conn, ~p"/return_codes/#{return_code}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Return code"

      assert_patch(show_live, ~p"/return_codes/#{return_code}/show/edit")

      assert show_live
             |> form("#return_code-form", return_code: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#return_code-form", return_code: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/return_codes/#{return_code}")

      html = render(show_live)
      assert html =~ "Return code updated successfully"
      assert html =~ "some updated code"
    end
  end
end
