defmodule ECommerceWeb.CartLive.Index do
  use ECommerceWeb, :live_view

  alias ECommerce.ShoppingCart

  @impl true
  def mount(_params, _session, socket) do
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
  def handle_info({ECommerceWeb.CartLive.FormComponent, {:updated, cart}}, socket) do
    {:noreply,
     socket
     |> assign(:cart, cart)
     |> assign(:changeset, ShoppingCart.change_cart(cart))}
  end

  @impl true
  def handle_event("remove", %{"product_id" => product_id}, socket) do
    {:ok, cart} = ShoppingCart.remove_item_from_cart(socket.assigns.cart, product_id)

    {:noreply,
     socket
     |> put_flash(:info, "Item removed from your cart")
     |> assign(:cart, cart)
     |> assign(:changeset, ShoppingCart.change_cart(cart))}
  end
end
