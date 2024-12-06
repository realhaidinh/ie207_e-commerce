defmodule ECommerceWeb.Admin.Order.Index do
  alias ECommerce.Orders
  use ECommerceWeb, :live_component

  @impl true
  def mount(socket) do
    {:ok, assign(socket, :orders, Orders.list_orders())}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.data_table
        table_id="orders-search-table"
        id="orders-table"
        rows={@orders}
        searchable="true"
        sortable="true"
        row_click={fn order -> JS.patch(~p"/admin/dashboard/sales/orders/#{order.id}") end}
      >
        <:col :let={order} label="Mã đơn hàng"><%= order.id %></:col>

        <:col :let={order} label="Tổng tiền"><%= order.total_price %></:col>

        <:col :let={order} label="Trạng thái"><%= order.status %></:col>
      </.data_table>
    </div>
    """
  end
end
