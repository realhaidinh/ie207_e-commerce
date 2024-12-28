defmodule ECommerceWeb.Public.ProductLive.Index do
  use ECommerceWeb, :live_view

  alias ECommerce.Catalog

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    page = get_page_no(Map.get(params, "page"))
    params = Map.put(params, "page", page)
    products = Catalog.search_product(params)

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

  defp get_page_no(nil), do: 1

  defp get_page_no(page_no) do
    String.to_integer(page_no)
  end

  defp self_path(socket, extra),
    do: ~p"/products?#{Enum.into(extra, socket.assigns.params)}"
end
