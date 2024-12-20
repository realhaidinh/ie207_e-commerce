defmodule ECommerceWeb.Public.CategoryLive.Show do
  alias ECommerce.Catalog.Category
  use ECommerceWeb, :live_view

  alias ECommerce.Catalog

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"category_id" => id} = params, _, socket) do
    category = Catalog.get_category!(id)
    products = Catalog.search_product(params)

    {:noreply,
     socket
     |> assign(:page_title, category.title)
     |> assign(:category, category)
     |> assign_parents_category(category)
     |> assign(:subcategories, Catalog.get_subcategories(category))
     |> stream(:products, products, reset: true)}
  end

  defp assign_parents_category(socket, %Category{} = category) do
    parent_ids = String.split(category.path, "/", trim: true)

    parents =
      Catalog.list_categories_by_ids(parent_ids)
      |> Enum.map(fn cat -> Map.put(cat, :url, "/categories/#{cat.id}") end)

    assign(socket, :parents, parents)
  end
end
