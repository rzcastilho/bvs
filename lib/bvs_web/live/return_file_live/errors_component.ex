defmodule BVSWeb.ReturnFileLive.ErrorsComponent do
  use BVSWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle><%= @return_file.name %></:subtitle>
      </.header>
      <.table id="errors" rows={@errors}>
        <:col :let={item} label="Sequence"><%= item.sequence %></:col>
        <:col :let={item} label="Type"><%= item.type %></:col>
        <:col :let={item} label="Document Type"><%= item.document_type %></:col>
        <:col :let={item} label="Document"><%= item.document %></:col>
        <:col :let={item} label="Error Code"><%= item.return_code.code %></:col>
        <:action :let={item}>
          <button phx-click={show_modal("item-details-modal-#{item.id}")}>Details</button>
        </:action>
      </.table>
      <.modal :for={item <- @errors} id={"item-details-modal-#{item.id}"}>
        <div>
          <.header>
            <%= item.return_code.code %> - <%= item.return_code.description %>
          </.header>
          <.table id={"item-details-#{item.id}"} rows={Enum.to_list(item.details)}>
            <:col :let={{key, _value}} label="Key"><%= key %></:col>
            <:col :let={{_key, value}} label="Value"><%= value %></:col>
          </.table>
        </div>
      </.modal>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end
end
