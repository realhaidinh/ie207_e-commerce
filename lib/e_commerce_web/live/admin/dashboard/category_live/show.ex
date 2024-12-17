defmodule ECommerceWeb.Admin.Dashboard.CategoryLive.Show do
  alias ECommerce.Catalog
  alias ECommerce.Catalog.Category

  use ECommerceWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :page_title, "Quản lý danh mục")}
  end

  @impl true
  def handle_params(%{"id" => id}, _uri, socket) do
    category = Catalog.get_category_with_product_count(id)
    socket = socket
    |> assign(:category, category)
    |> stream(:categories, Catalog.get_subcategories(category), reset: true)
    {:noreply, apply_action(socket, socket.assigns.live_action)}
  end

  def apply_action(socket, :new) do
    %{category: category} = socket.assigns

    subcategory = %Category{
      path: Catalog.get_subcategory_path(category),
      level: category.level + 1
    }

    assign(socket, :subcategory, subcategory)
  end

  def apply_action(socket, _), do: socket
  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    category = Catalog.get_category!(id)
    {_, _} = Catalog.delete_category(category)
    {:noreply, stream_delete(socket, :categories, category)}
  end

  def handle_event("show-subcategories", %{"id" => id}, socket) do
    category = Catalog.get_category_with_product_count(id)
    socket =
      if Map.get(socket.assigns.streams, category.title) do
        socket
      else
        category = Map.put(category, :categories, Catalog.get_subcategories(category))
        socket
        |> stream_insert(:categories, category)
        |> stream(category.title, [])
      end
    {:noreply, socket}
  end
  @impl true
  def handle_info({:updated, category}, socket) do
    {:noreply, assign(socket, :category, category)}
  end

  def handle_info({:created, category}, socket) do
    {:noreply, stream_insert(socket, :categories, category)}
  end

end
