defmodule ECommerceWeb.Admin.Dashboard.CategoryIndex do
  use ECommerceWeb, :live_component
  alias ECommerce.Catalog

  @impl true
  def mount(socket) do
    {:ok, assign(socket, :categories, Catalog.list_root_categories())}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.table
        id="categories"
        rows={@categories}
        row_click={
          fn category -> JS.patch(~p"/admin/dashboard/catalog/categories/#{category.id}") end
        }
      >
        <:col :let={category} label="Tên danh mục"><%= category.title %></:col>
      </.table>
    </div>
    """
  end
end
