defmodule ECommerceWeb.Admin.Dashboard.CategoryShow do
  use ECommerceWeb, :live_component
  alias ECommerce.Catalog

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  @impl true
  def update(assigns, socket) do
    category = Catalog.get_category!(assigns.item_id)
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:category, category)
     |> assign(:subcategories, Catalog.get_subcategories(category))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="category-information">
        <.list>
          <:item title="Mã danh mục"><%= @category.id %></:item>

          <:item title="Tên danh mục"><%= @category.title %></:item>
        </.list>
      </div>

      <div class="subcategories-table">
        <h1>Danh mục con</h1>

        <.table
          id="subcategories"
          rows={@subcategories}
          row_click={
            fn category -> JS.patch(~p"/admin/dashboard/catalog/categories/#{category.id}") end
          }
        >
          <:col :let={category} label="Mã danh mục"><%= category.id %></:col>

          <:col :let={category} label="Tên danh mục"><%= category.title %></:col>
        </.table>
      </div>
    </div>
    """
  end
end
