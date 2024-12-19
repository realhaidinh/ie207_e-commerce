defmodule ECommerceWeb.Public.ProductLive.Index do
  use ECommerceWeb, :live_view

  alias ECommerce.Catalog

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    params = Map.put(params, "limit", 20)
    products = Catalog.search_product(params)

    {:noreply,
     socket
     |> assign(:page_title, Map.get(params, "keyword", ""))
     |> stream(:products, products, reset: true)}
  end
end
