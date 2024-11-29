defmodule ECommerceWeb.Admin.Dashboard.ProductShow do
  use ECommerceWeb, :live_component
  alias ECommerce.Catalog

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:product, fn -> Catalog.get_product!(assigns.item_id) end)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
    <.list>
      <:item title="Title"><%= @product.title %></:item>

      <:item title="Description"><%= @product.description %></:item>

      <:item title="Price"><%= @product.price %></:item>

      <:item title="Stock"><%= @product.stock %></:item>

      <:item title="Sold"><%= @product.sold %></:item>

      <:item title="Slug"><%= @product.slug %></:item>

      <:item title="Review"><%= @product.rating %></:item>
    </.list>
    </div>
    """
  end
end
