defmodule ECommerceWeb.Public.ProductLive.Index do
  use ECommerceWeb, :live_view

  alias ECommerce.Catalog

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    products = Catalog.search_product(params)
    page = Map.get(params, "page", "1") |> String.to_integer()

    {:noreply,
     socket
     |> assign(:page_title, Map.get(params, "keyword", ""))
     |> assign(:page, page)
     |> assign(:total_page, 1)
     |> assign(:params, params)
     |> stream(:products, products, reset: true)}
  end

  @impl true
  def handle_event("prev_page", _params, socket) do
    {:noreply, push_patch(socket, to: self_path(socket, %{"page" => socket.assigns.page - 1}))}
  end

  def handle_event("next_page", _params, socket) do
    {:noreply, push_patch(socket, to: self_path(socket, %{"page" => socket.assigns.page + 1}))}
  end

  defp self_path(socket, extra),
    do: ~p"/products?#{Enum.into(extra, socket.assigns.params)}"
end
