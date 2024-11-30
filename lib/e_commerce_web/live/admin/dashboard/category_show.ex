defmodule ECommerceWeb.Admin.Dashboard.CategoryShow do
  alias ECommerce.Catalog.Category
  use ECommerceWeb, :live_component
  alias ECommerce.Catalog

  @impl true
  def render(assigns) do
    ~H"""
    <div class="relative">
      <.link phx-click="open_edit_category_modal" phx-target={@myself}>
        <.button>Chỉnh sửa danh mục</.button>
      </.link>
      <.link phx-click="open_create_subcategory_modal" phx-target={@myself}>
        <.button>Tạo danh mục con</.button>
      </.link>
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
      <.modal
        :if={@is_modal_open}
        id="category-modal"
        show
        on_cancel={JS.push("close_modal", target: @myself)}
      >
        <.live_component
          module={ECommerceWeb.Admin.Dashboard.CategoryForm}
          id={@category.id}
          item_id={@item_id}
          action={@action}
          category={if @action == :edit, do: @category, else: @subcategory}
        />
      </.modal>
    </div>
    """
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
  def handle_event("open_edit_category_modal", _, socket) do
    notify_parent(:open_modal)
    {:noreply, assign(socket, :action, :edit)}
  end

  def handle_event("open_create_subcategory_modal", _, socket) do
    notify_parent(:open_modal)
    %{category: category} = socket.assigns

    subcategory = %Category{
      path: Catalog.get_subcategory_path(category),
      level: category.level + 1
    }

    {:noreply,
     assign(socket, :subcategory, subcategory)
     |> assign(:action, :new)}
  end

  def handle_event("close_modal", _, socket) do
    notify_parent(:close_modal)
    {:noreply, socket}
  end

  defp notify_parent(msg), do: send(self(), msg)
end
