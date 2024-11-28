defmodule ECommerceWeb.CheckoutLive.Success do
  alias ECommerce.Orders
  use ECommerceWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        Đã đặt thành công đơn hàng <%= @order.id %>
      </.header>
      <.table
        id="order-products"
        rows={@order.line_items}
        row_click={fn item -> JS.navigate(~p"/products/#{item.product.id}") end}
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

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"order_id" => order_id}, _uri, socket) do
    %{current_user: %{id: user_id}} = socket.assigns
    order = Orders.get_order!(user_id, order_id)
    {:noreply, assign(socket, :order, order)}
  end
end
