defmodule ECommerceWeb.Public.ProductLive.Show do
  use ECommerceWeb, :live_view

  alias ECommerce.Catalog
  alias ECommerce.ShoppingCart

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    product = Catalog.get_product!(id, [:rating, :categories, :images])

    {:noreply,
     socket
     |> assign(:page_title, product.title)
     |> assign(:product, product)
     |> assign(:reviews, Catalog.list_reviews_by_product(id))}
  end

  @impl true
  def handle_event("add", _, socket) do
    socket =
      if socket.assigns.current_user do
        case ShoppingCart.add_item_to_cart(socket.assigns.cart, socket.assigns.product.id) do
          {:ok, _cart} ->
            put_flash(socket, :info, "Sản phẩm đã được thêm vào giỏ hàng")

          {:error, _changeset} ->
            put_flash(socket, :error, "There was an error adding the item to your cart")
        end
      else
        redirect(socket, to: ~p"/users/log_in")
      end

    {:noreply, socket}
  end

  defp get_category_pages(categories) do
    Enum.map(categories, &Map.put(&1, :url, "/categories/#{&1.id}"))
  end
end
