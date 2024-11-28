defmodule ECommerceWeb.OrderLive.Show do
  use ECommerceWeb, :live_view
  alias ECommerce.Orders
  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _uri, socket) do
    order = Orders.get_order!(socket.assigns.current_user.id, id)

    {:noreply,
     socket
     |> assign(:page_title, "Show Order")
     |> assign(:order, order)}
  end
end
