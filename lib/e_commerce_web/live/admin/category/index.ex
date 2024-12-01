defmodule ECommerceWeb.Admin.Category.Index do
  alias ECommerce.Catalog.Category
  use ECommerceWeb, :live_component
  alias ECommerce.Catalog
  @impl true
  def render(assigns) do
    ~H"""
    <div class="relative overflow-x-auto">
      <.link phx-click="open_new_category_modal" phx-target={@myself}>
        <.button>Tạo danh mục mới</.button>
      </.link>
      <.table
        id="categories"
        rows={@categories}
        row_click={
          fn category -> JS.patch(~p"/admin/dashboard/catalog/categories/#{category.id}") end
        }
      >
        <:col :let={category} label="Tên danh mục"><%= category.title %></:col>
      </.table>
      <.modal
        :if={@is_modal_open}
        show
        id="category-modal"
        on_cancel={JS.push("close_new_modal", target: @myself)}
      >
        <.live_component
          module={ECommerceWeb.Admin.Category.Form}
          id={:category}
          item_id={@item_id}
          action={:new}
          category={@category}
        />
      </.modal>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:categories, Catalog.list_root_categories())}
  end

  @impl true
  def handle_event("open_new_category_modal", _, socket) do
    notify_parent(:open_modal)
    {:noreply, assign(socket, :category, %Category{})}
  end

  def handle_event("close_new_modal", _, socket) do
    notify_parent(:close_modal)
    {:noreply, socket}
  end

  defp notify_parent(msg), do: send(self(), msg)
end
