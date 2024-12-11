defmodule ECommerceWeb.Public.HomeLive do
  alias ECommerce.Catalog
  use ECommerceWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <div class="m-16">
      <header>Trang chủ</header>
      
      <div class="home-category-list">
        <span>DANH MỤC</span>
        <div class="categories">
          <.link
            :for={{dom_id, category} <- @streams.categories}
            id={dom_id}
            navigate={~p"/categories/#{category.id}"}
          >
            <%= category.title %>
          </.link>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    socket = stream(socket, :categories, Catalog.list_root_categories())
    {:ok, socket}
  end
end
