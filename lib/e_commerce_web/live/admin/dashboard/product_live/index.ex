defmodule ECommerceWeb.Admin.Dashboard.ProductLive.Index do
  alias ECommerce.Catalog.Product
  alias ECommerce.Catalog
  use ECommerceWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Quản lý sản phẩm")
     |> assign(:products, Catalog.list_products())}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    {:noreply, apply_action(socket, params, socket.assigns.live_action)}
  end

  def apply_action(socket, %{"id" => id}, :edit) do
    assign(socket, :product, Catalog.get_product!(id))
  end

  def apply_action(socket, _, :new) do
    assign(socket, :product, %Product{})
  end

  def apply_action(socket, _, _), do: assign(socket, :product, nil)

  @impl true
  def handle_info(:saved, socket) do
    {:noreply, assign(socket, :products, Catalog.list_products())}
  end
end
