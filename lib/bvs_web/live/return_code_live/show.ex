defmodule BVSWeb.ReturnCodeLive.Show do
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
     |> assign(:return_code, Negativation.get_return_code!(id))}
  end

  defp page_title(:show), do: "Show Return code"
  defp page_title(:edit), do: "Edit Return code"
end
