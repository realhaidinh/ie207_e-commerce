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

  @impl true
  def handle_event("confirm-shipped", _unsigned_params, socket) do
    {:ok, order} = Orders.update_order(socket.assigns.order, %{status: :"Đã giao hàng"})

    {:noreply,
     socket
     |> assign(:order, order)
     |> put_flash(:info, "Đơn hàng #{order.id} đã giao thành công")}
  end
end
