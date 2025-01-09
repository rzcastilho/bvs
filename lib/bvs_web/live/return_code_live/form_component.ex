defmodule BVSWeb.ReturnCodeLive.FormComponent do
  use BVSWeb, :live_component

  alias BVS.Negativation

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage return_code records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="return_code-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:code]} type="text" label="Code" />
        <.input field={@form[:description]} type="text" label="Description" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Return code</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{return_code: return_code} = assigns, socket) do
    changeset = Negativation.change_return_code(return_code)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"return_code" => return_code_params}, socket) do
    changeset =
      socket.assigns.return_code
      |> Negativation.change_return_code(return_code_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"return_code" => return_code_params}, socket) do
    save_return_code(socket, socket.assigns.action, return_code_params)
  end

  defp save_return_code(socket, :edit, return_code_params) do
    case Negativation.update_return_code(socket.assigns.return_code, return_code_params) do
      {:ok, return_code} ->
        notify_parent({:saved, return_code})

        {:noreply,
         socket
         |> put_flash(:info, "Return code updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_return_code(socket, :new, return_code_params) do
    case Negativation.create_return_code(return_code_params) do
      {:ok, return_code} ->
        notify_parent({:saved, return_code})

        {:noreply,
         socket
         |> put_flash(:info, "Return code created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
