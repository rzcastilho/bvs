defmodule BVSWeb.ReturnFileLive.FormComponent do
  use BVSWeb, :live_component

  alias BVS.Negativation

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage return_file records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="return_file-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input
          field={@form[:status]}
          type="select"
          options={["found", "downloaded", "processed", "reviewed", "error"]}
          label="Status"
        />
        <.input field={@form[:notes]} type="text" label="Notes" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Return file</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{return_file: return_file} = assigns, socket) do
    changeset = Negativation.change_return_file(return_file)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"return_file" => return_file_params}, socket) do
    changeset =
      socket.assigns.return_file
      |> Negativation.change_return_file(return_file_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"return_file" => return_file_params}, socket) do
    save_return_file(socket, socket.assigns.action, return_file_params)
  end

  defp save_return_file(socket, :edit, return_file_params) do
    case Negativation.update_return_file(socket.assigns.return_file, return_file_params) do
      {:ok, return_file} ->
        notify_parent({:saved, return_file})

        {:noreply,
         socket
         |> put_flash(:info, "Return file updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_return_file(socket, :new, return_file_params) do
    case Negativation.create_return_file(return_file_params) do
      {:ok, return_file} ->
        notify_parent({:saved, return_file})

        {:noreply,
         socket
         |> put_flash(:info, "Return file created successfully")
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
