defmodule ECommerceWeb.Public.CategoryLive.Show do
  use ECommerceWeb, :live_view

  alias ECommerce.Catalog

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    category = Catalog.get_category!(id)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:category, category)
     |> assign(:subcategories, Catalog.get_subcategories(category))}
  end

  defp page_title(:show), do: "Show Category"
end
