defmodule ECommerceWeb.Admin.Dashboard.OrderIndex do
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
      <.table
        id="orders-table"
        rows={@orders}
        row_click={fn order -> JS.patch(~p"/admin/dashboard/sales/orders/#{order.id}") end}
      >
        <:col :let={order} label="Mã đơn hàng"><%= order.id %></:col>

        <:col :let={order} label="Tổng tiền"><%= order.total_price %></:col>

        <:col :let={order} label="Trạng thái"><%= order.status %></:col>
      </.table>
    </div>
    """
  end
end
