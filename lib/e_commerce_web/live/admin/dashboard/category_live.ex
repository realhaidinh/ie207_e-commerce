defmodule ECommerceWeb.Admin.Dashboard.CategoryLive do
  use ECommerceWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        Quản lý danh mục
      </.header>
      <%= render_category(assigns, @live_action) %>
    </div>
    """
  end


  def render_category(assigns, :categories) do
    ~H"""
    <.table
      id="categories"
      rows={@categories}
      row_click={fn category -> JS.patch(~p"/admin/dashboard/catalog/categories/#{category.id}") end}
    >
      <:col :let={category} label="Tên danh mục"><%= category.title %></:col>
    </.table>
    """
  end

  def render_category(assigns, :category) do
    ~H"""
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
        row_click={fn category -> JS.patch(~p"/admin/dashboard/catalog/categories/#{category.id}") end}
      >
        <:col :let={category} label="Mã danh mục"><%= category.id %></:col>
        <:col :let={category} label="Tên danh mục"><%= category.title %></:col>
      </.table>
    </div>
    """
  end
end
