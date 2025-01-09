defmodule BVSWeb.ReturnFileLive.Show do
  use BVSWeb, :live_view

  alias BVS.Negativation

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:return_file, Negativation.get_return_file!(id))}
  end

  defp page_title(:show), do: "Show Return file"
  defp page_title(:edit), do: "Edit Return file"
end
