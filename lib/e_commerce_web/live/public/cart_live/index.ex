defmodule ECommerceWeb.Public.CartLive.Index do
  use ECommerceWeb, :live_view

  alias ECommerce.ShoppingCart

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: ShoppingCart.subscribe()
    {:ok, assign(socket, :page_title, "Listing Cart")}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:changeset, ShoppingCart.change_cart(socket.assigns.cart))
  end

  @impl true
  def handle_info({:cart_updated, updated_cart}, socket) do
    {:noreply,
     socket
     |> assign(:cart, updated_cart)
     |> assign(:changeset, ShoppingCart.change_cart(updated_cart))}
  end

  @impl true
  def handle_event("remove", %{"product_id" => product_id}, socket) do
    {:ok, _cart} = ShoppingCart.remove_item_from_cart(socket.assigns.cart, product_id)

    {:noreply,
     socket
     |> put_flash(:info, "Item removed from your cart")}
  end
end
