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
    parent_ids = String.split(category.path, "/", trim: true)

    parents =
      Catalog.list_categories_by_ids(parent_ids)
      |> Enum.map(fn cat -> Map.put(cat, :url, "/categories/#{cat.id}") end)

    products = Catalog.list_products_by_category(id)

    {:noreply,
     socket
     |> assign(:page_title, category.title)
     |> assign(:category, category)
     |> assign(:parents, parents)
     |> assign(:subcategories, Catalog.get_subcategories(category))
     |> stream(:products, products, reset: true)}
  end
end
