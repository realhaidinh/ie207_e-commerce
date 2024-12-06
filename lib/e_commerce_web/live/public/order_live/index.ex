defmodule ECommerceWeb.Public.OrderLive.Index do
  use ECommerceWeb, :live_view
  alias ECommerce.Orders
  @impl true
  def mount(_params, _session, socket) do
    {:ok, load_user_orders(socket)}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    {:noreply, assign(socket, :page_title, "Listing orders")}
  end

  def load_user_orders(socket) do
    orders = Orders.list_user_orders(socket.assigns.current_user.id)
    assign(socket, :orders, orders)
  end
end
