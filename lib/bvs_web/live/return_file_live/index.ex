defmodule BVSWeb.ReturnFileLive.Index do
  use BVSWeb, :live_view

  alias BVS.Negativation
  alias BVS.Negativation.ReturnFile

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :return_files, Negativation.list_return_files())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Return file")
    |> assign(:return_file, Negativation.get_return_file!(id))
  end

  defp apply_action(socket, :errors, %{"id" => id}) do
    socket
    |> assign(:page_title, "Errors Details")
    |> assign(:return_file, Negativation.get_return_file!(id))
    |> assign(:errors, Negativation.list_items_with_errors_by_return_file_id(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Return file")
    |> assign(:return_file, %ReturnFile{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Return files")
    |> assign(:return_file, nil)
  end

  @impl true
  def handle_info({BVSWeb.ReturnFileLive.FormComponent, {:saved, return_file}}, socket) do
    {:noreply, stream_insert(socket, :return_files, return_file)}
  end

  @impl true
  def handle_event("reviewed", %{"id" => id}, socket) do
    {:ok, return_file} = Negativation.update_return_file_status_by_id(id, :reviewed)

    {:noreply, stream_insert(socket, :return_files, return_file)}
  end

  @impl true
  def handle_event("pending", %{"id" => id}, socket) do
    {:ok, return_file} = Negativation.update_return_file_status_by_id(id, :pending)

    {:noreply, stream_insert(socket, :return_files, return_file)}
  end
end
