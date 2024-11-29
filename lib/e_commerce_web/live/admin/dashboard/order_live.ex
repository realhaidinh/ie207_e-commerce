defmodule ECommerceWeb.Admin.Dashboard.OrderLive do
  alias ECommerce.Orders
  use ECommerceWeb, :live_view
  @impl true
  def mount(_params, session, socket) do
    if connected?(socket), do: Phoenix.PubSub.subscribe(ECommerce.PubSub, "dashboard")
    {:ok, apply_action(socket, session)}
  end

  @impl true
  def handle_info(msg, socket) do
    socket = apply_action(socket, msg)
    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <%= case assigns do %>
        <% %{action: action} -> %>
          <%= render_order(assigns, action) %>
        <% _ -> %>
      <% end %>
    </div>
    """
  end

  def apply_action(socket, %{"id" => id}) when not is_nil(id) do
    assign(socket, :order, Orders.get_order!(id))
    |> assign(:action, :show)
  end

  def apply_action(socket, _) do
    assign_new(socket, :orders, fn -> Orders.list_orders() end)
    |> assign(:action, :index)
  end

  def render_order(assigns, :index) do
    ~H"""
    <.table
      id="orders-table"
      rows={@orders}
      row_click={fn order -> JS.patch(~p"/admin/dashboard/sales/orders/#{order.id}") end}
    >
      <:col :let={order} label="Mã đơn hàng"><%= order.id %></:col>

      <:col :let={order} label="Tổng tiền"><%= order.total_price %></:col>

      <:col :let={order} label="Trạng thái"><%= order.status %></:col>
    </.table>
    """
  end

  def render_order(assigns, :show) do
    ~H"""
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
    """
  end
end
