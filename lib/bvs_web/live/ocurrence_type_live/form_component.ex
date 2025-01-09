defmodule BVSWeb.OcurrenceTypeLive.FormComponent do
  use BVSWeb, :live_component

  alias BVS.Negativation

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage ocurrence_type records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="ocurrence_type-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:code]} type="text" label="Code" />
        <.input field={@form[:description]} type="text" label="Description" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Ocurrence type</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{ocurrence_type: ocurrence_type} = assigns, socket) do
    changeset = Negativation.change_ocurrence_type(ocurrence_type)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"ocurrence_type" => ocurrence_type_params}, socket) do
    changeset =
      socket.assigns.ocurrence_type
      |> Negativation.change_ocurrence_type(ocurrence_type_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"ocurrence_type" => ocurrence_type_params}, socket) do
    save_ocurrence_type(socket, socket.assigns.action, ocurrence_type_params)
  end

  defp save_ocurrence_type(socket, :edit, ocurrence_type_params) do
    case Negativation.update_ocurrence_type(socket.assigns.ocurrence_type, ocurrence_type_params) do
      {:ok, ocurrence_type} ->
        notify_parent({:saved, ocurrence_type})

        {:noreply,
         socket
         |> put_flash(:info, "Ocurrence type updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_ocurrence_type(socket, :new, ocurrence_type_params) do
    case Negativation.create_ocurrence_type(ocurrence_type_params) do
      {:ok, ocurrence_type} ->
        notify_parent({:saved, ocurrence_type})

        {:noreply,
         socket
         |> put_flash(:info, "Ocurrence type created successfully")
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
