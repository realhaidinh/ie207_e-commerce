defmodule ECommerceWeb.Admin.Dashboard.CategoryLive.Index do
  alias ECommerce.Catalog
  alias ECommerce.Catalog.Category
  use ECommerceWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket |> assign(:page_title, "Quản lý danh mục") |> stream(:stream_init, [])}
  end

  @impl true
  def handle_params(params, _url, socket) do
    socket = assign(socket, :categories, Catalog.list_root_categories())
    {:noreply, apply_action(socket, params, socket.assigns.live_action)}
  end

  def apply_action(socket, _params, :index) do
    assign(socket, :category, nil)
  end

  def apply_action(socket, _params, :new) do
    assign(socket, :category, %Category{})
  end

  def apply_action(socket, %{"id" => id}, :edit) do
    assign(socket, :category, Catalog.get_category!(id))
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    category = Catalog.get_category!(id)
    {_, _} = Catalog.delete_category(category)

    {:noreply, push_patch(socket, to: ~p"/admin/dashboard/catalog/category")}
  end

  def handle_event("show-subcategories", %{"id" => id}, socket) do
    category = Catalog.get_category!(id)

    socket =
      if socket.assigns.streams[category.title] do
        socket
      else
        stream(socket, category.title, Catalog.get_subcategories(category))
      end

    {:noreply, socket}
  end
end
