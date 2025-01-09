defmodule BVSWeb.ReturnCodeLive.Index do
  use BVSWeb, :live_view

  alias BVS.Negativation
  alias BVS.Negativation.ReturnCode

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :return_codes, Negativation.list_return_codes())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Return code")
    |> assign(:return_code, Negativation.get_return_code!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Return code")
    |> assign(:return_code, %ReturnCode{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Return codes")
    |> assign(:return_code, nil)
  end

  @impl true
  def handle_info({BVSWeb.ReturnCodeLive.FormComponent, {:saved, return_code}}, socket) do
    {:noreply, stream_insert(socket, :return_codes, return_code)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    return_code = Negativation.get_return_code!(id)
    {:ok, _} = Negativation.delete_return_code(return_code)

    {:noreply, stream_delete(socket, :return_codes, return_code)}
  end
end
