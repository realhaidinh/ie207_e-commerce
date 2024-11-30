defmodule ECommerceWeb.Admin.Dashboard.OrderShow do
  alias ECommerce.Orders
  use ECommerceWeb, :live_component

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:order, fn -> Orders.get_order!(assigns.item_id) end)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        Mã đơn hàng: <%= @order.id %> |
        Trạng thái đơn hàng: <%= @order.status %>
      </.header>

      <.table
        id="order-products"
        rows={@order.line_items}
        row_click={fn item -> JS.patch(~p"/admin/dashboard/catalog/products/#{item.product.id}") end}
      >
        <:col :let={item} label="Sản phẩm"><%= item.product.title %></:col>

        <:col :let={item} label="Đơn giá"><%= item.price %></:col>

        <:col :let={item} label="Số lượng"><%= item.quantity %></:col>

        <:col :let={item} label="Thành tiền"><%= item.price * item.quantity %></:col>
      </.table>

      <h1>Tổng tiền <%= @order.total_price %></h1>

      <p>Họ tên người nhận: <%= @order.buyer_name %></p>

      <p>Địa chỉ nhận hàng: <%= @order.buyer_address %></p>

      <p>Số điện thoại nhận hàng: <%= @order.buyer_phone %></p>
    </div>
    """
  end
end
