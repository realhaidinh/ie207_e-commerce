defmodule ECommerceWeb.Admin.Product.Index do
  alias ECommerce.Catalog
  use ECommerceWeb, :live_component
  @impl true
  def mount(socket) do
    {:ok, assign(socket, :products, Catalog.list_products())}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
    <.header>Danh sách sản phẩm</.header>
      <.data_table
        table_id="products-search-table"
        id="products-table"
        rows={@products}
        searchable="true"
        sortable="true"
        row_click={fn product -> JS.patch(~p"/admin/dashboard/catalog/products/#{product}") end}
      >
        <:col :let={product} label="Tên sản phẩm"><%= product.title %></:col>

        <:col :let={product} label="Giá"><%= product.price %></:col>

        <:col :let={product} label="Tồn kho"><%= product.stock %></:col>

        <:col :let={product} label="Đã bán"><%= product.sold %></:col>

        <:col :let={product} label="Đánh giá"><%= product.rating %></:col>
      </.data_table>
    </div>
    """
  end
end
