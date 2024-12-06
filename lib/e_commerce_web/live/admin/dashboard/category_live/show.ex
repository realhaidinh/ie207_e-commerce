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
    category = Catalog.get_category!(id)

    socket =
      socket
      |> assign(:category, category)
      |> assign(:subcategories, Catalog.get_subcategories(category))

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
    %{category: %{id: id}} = socket.assigns
    {:noreply, push_patch(socket, to: ~p"/admin/dashboard/catalog/category/#{id}")}
  end
end