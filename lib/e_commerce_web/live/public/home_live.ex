defmodule ECommerceWeb.Public.HomeLive do
  alias ECommerce.Catalog
  use ECommerceWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex pt-6 justify-between">
      <div class="overflow-y-auto bg-slate-50 p-8 basis-1/5">
        <span class="font-semibold hover:underline hover:cursor-pointer" phx-click={JS.navigate(~p"/categories")}>DANH MỤC</span>
        <div class="flex flex-col flex-wrap mt-8">
          <.link
            :for={{dom_id, category} <- @streams.categories}
            id={dom_id}
            navigate={~p"/categories/#{category.id}"}
            class="mb-2 hover:underline"
          >
            <%= category.title %>
          </.link>
        </div>
      </div>
      <div class="flex p-4 bg-slate-50 basis-[75%]">
        <span class="font-semibold">Sản phẩm bạn có thể quan tâm</span>
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
