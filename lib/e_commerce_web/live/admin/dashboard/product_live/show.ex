defmodule ECommerceWeb.Admin.Dashboard.ProductLive.Show do
  alias ECommerce.Catalog
  use ECommerceWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :page_title, "Quản lý sản phẩm")}
  end

  @impl true
  def handle_params(%{"id" => id}, _uri, socket) do
    {:noreply, assign(socket, :product, Catalog.get_product!(id))}
  end
end
