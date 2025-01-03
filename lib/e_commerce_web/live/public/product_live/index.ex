defmodule ECommerceWeb.Public.ProductLive.Index do
  use ECommerceWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    {:noreply,
     socket
     |> assign(:page_title, Map.get(params, "keyword", ""))
     |> assign(:params, params)
     |> assign(:current_path, "/products")}
  end
end
