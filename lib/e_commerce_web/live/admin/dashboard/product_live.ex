defmodule ECommerceWeb.Admin.Dashboard.ProductLive do
  use ECommerceWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        Quản lý sản phẩm
      </.header>
      <%= render_product(assigns, @live_action) %>
    </div>
    """
  end

  def render_product(assigns, :products) do
    ~H"""
    <.table
      id="products"
      rows={@products}
      row_click={fn product -> JS.patch(~p"/admin/dashboard/catalog/products/#{product}") end}
    >
      <:col :let={product} label="Tên sản phẩm"><%= product.title %></:col>

      <:col :let={product} label="Giá"><%= product.price %></:col>

      <:col :let={product} label="Tồn kho"><%= product.stock %></:col>

      <:col :let={product} label="Đã bán"><%= product.sold %></:col>

      <:col :let={product} label="Đánh giá"><%= product.rating %></:col>
    </.table>
    """
  end

  def render_product(assigns, :product) do
    ~H"""
    <.list>
      <:item title="Title"><%= @product.title %></:item>

      <:item title="Description"><%= @product.description %></:item>

      <:item title="Price"><%= @product.price %></:item>

      <:item title="Stock"><%= @product.stock %></:item>

      <:item title="Sold"><%= @product.sold %></:item>

      <:item title="Slug"><%= @product.slug %></:item>

      <:item title="Review"><%= @product.rating %></:item>
    </.list>
    """
  end
end
