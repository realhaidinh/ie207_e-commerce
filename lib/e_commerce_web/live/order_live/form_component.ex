defmodule ECommerceWeb.OrderLive.FormComponent do
  alias ECommerce.Orders.Order
  use ECommerceWeb, :live_component
  @impl true
  def render(assigns) do
    ~H"""
    <div></div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end
end
