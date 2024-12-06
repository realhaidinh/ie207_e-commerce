defmodule ECommerceWeb.Admin.Dashboard.ProductLive.FormComponent do
  alias ECommerce.Catalog.Category
  alias ECommerce.Catalog
  alias ECommerce.Catalog.Product
  use ECommerceWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <section class="bg-white dark:bg-gray-900">
        <.simple_form for={@form} id="product-form" phx-target={@myself} phx-submit="save">
          <.input field={@form[:title]} type="text" label="Tên sản phẩm" />
          <.input field={@form[:description]} type="text" label="Mô tả sản phẩm" />
          <.input field={@form[:price]} type="text" label="Giá bán" />
          <.input field={@form[:stock]} type="number" label="Kho" />
          <.input
            field={@form[:category_id]}
            type="select"
            options={category_opts(@changeset)}
            label="Danh mục"
          />
          <:actions>
            <.button phx-disable-with="...">Lưu</.button>
          </:actions>
        </.simple_form>
      </section>
    </div>
    """
  end

  @impl true
  def update(%{product: product} = assigns, socket) do
    attrs = %{"category_id" => get_product_main_category_id(product)}

    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:changeset, fn ->
       Catalog.change_product(product, attrs)
     end)
     |> assign_new(:form, fn %{changeset: changeset} ->
       to_form(changeset)
     end)}
  end

  defp category_opts(changeset) do
    existing_id =
      changeset
      |> Ecto.Changeset.get_change(:categories, [])
      |> Enum.max_by(& &1.data.level, fn -> -1 end)

    for cat <- Catalog.list_categories(),
        do: [key: cat.title, value: cat.id, selected: cat.id == existing_id]
  end

  defp get_product_main_category_id(%Product{categories: %Ecto.Association.NotLoaded{}}), do: -1
  defp get_product_main_category_id(%Product{categories: categories}) do
    case Enum.max_by(categories, & &1.level, fn -> -1 end) do
      %Category{id: id} -> id
      _ -> -1
    end
  end
  @impl true
  def handle_event("save", %{"product" => product_params}, socket) do
    save_product(socket, socket.assigns.action, product_params)
  end

  def save_product(socket, :edit, product_params) do
    case Catalog.update_product(socket.assigns.product, product_params) do
      {:ok, _product} ->
        notify_parent(:saved)
        {:noreply, push_patch(socket, to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  def save_product(socket, :new, product_params) do
    case Catalog.create_product(product_params) do
      {:ok, _product} ->
        notify_parent(:saved)
        {:noreply, push_patch(socket, to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), msg)
end
