defmodule ECommerceWeb.Admin.Dashboard.OrderLive.Show do
  alias ECommerce.Orders
  use ECommerceWeb, :live_view

  @impl true
  def mount(_, _session, socket) do
    {:ok, assign(socket, :page_title, "Quản lý đơn hàng")}
  end

  @impl true
  def handle_params(%{"id" => id}, _uri, socket) do
    {:noreply, assign(socket, :order, Orders.get_order!(id))}
  end
end
