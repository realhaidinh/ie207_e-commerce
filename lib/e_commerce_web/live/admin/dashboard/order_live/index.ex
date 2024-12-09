defmodule ECommerceWeb.Admin.Dashboard.OrderLive.Index do
alias ECommerce.Orders
  use ECommerceWeb, :live_view

  @impl true
  def mount(_, _session, socket) do
    {:ok, assign(socket, :page_title, "Quản lý hóa đơn")}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    {:noreply, stream(socket, :orders, Orders.list_orders())}
  end
end
