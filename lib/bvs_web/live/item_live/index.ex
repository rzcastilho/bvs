defmodule BVSWeb.ItemLive.Index do
  use BVSWeb, :live_view

  alias BVS.Negativation
  alias BVS.Negativation.Item

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :items, Negativation.list_items())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Item")
    |> assign(:item, Negativation.get_item!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Item")
    |> assign(:item, %Item{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Items")
    |> assign(:item, nil)
  end

  @impl true
  def handle_info({BVSWeb.ItemLive.FormComponent, {:saved, item}}, socket) do
    {:noreply, stream_insert(socket, :items, item)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    item = Negativation.get_item!(id)
    {:ok, _} = Negativation.delete_item(item)

    {:noreply, stream_delete(socket, :items, item)}
  end
end
