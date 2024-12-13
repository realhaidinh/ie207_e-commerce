defmodule ECommerceWeb.Public.OrderLive.Show do
  use ECommerceWeb, :live_view
  alias ECommerce.Orders
  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket, layout: {ECommerceWeb.Layouts, :public_profile}}
  end

  @impl true
  def handle_params(%{"id" => id}, _uri, socket) do
    order = Orders.get_order!(socket.assigns.current_user.id, id)

    {:noreply,
     socket
     |> assign(:page_title, "Đơn hàng #{order.id}")
     |> assign(:order, order)}
  end
end
