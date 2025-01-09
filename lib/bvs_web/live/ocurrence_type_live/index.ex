defmodule BVSWeb.OcurrenceTypeLive.Index do
  use BVSWeb, :live_view

  alias BVS.Negativation
  alias BVS.Negativation.OcurrenceType

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :ocurrence_types, Negativation.list_ocurrence_types())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Ocurrence type")
    |> assign(:ocurrence_type, Negativation.get_ocurrence_type!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Ocurrence type")
    |> assign(:ocurrence_type, %OcurrenceType{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Ocurrence types")
    |> assign(:ocurrence_type, nil)
  end

  @impl true
  def handle_info({BVSWeb.OcurrenceTypeLive.FormComponent, {:saved, ocurrence_type}}, socket) do
    {:noreply, stream_insert(socket, :ocurrence_types, ocurrence_type)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    ocurrence_type = Negativation.get_ocurrence_type!(id)
    {:ok, _} = Negativation.delete_ocurrence_type(ocurrence_type)

    {:noreply, stream_delete(socket, :ocurrence_types, ocurrence_type)}
  end
end
