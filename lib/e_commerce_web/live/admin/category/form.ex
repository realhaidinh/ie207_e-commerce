defmodule ECommerceWeb.Admin.Category.Form do
  use ECommerceWeb, :live_component
  alias ECommerce.Catalog
  @impl true
  def render(assigns) do
    ~H"""
    <section class="bg-white dark:bg-gray-900">
      <.simple_form for={@form} id="category-form" phx-target={@myself} phx-submit="save">
        <.input field={@form[:title]} type="text" label="Title" />
        <:actions>
          <.button phx-disable-with="Saving...">Lưu</.button>
        </:actions>
      </.simple_form>
    </section>
    """
  end

  @impl true
  def update(%{category: category} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:form, to_form(Catalog.change_category(category)))}
  end

  @impl true
  def handle_event("save", %{"category" => category_params}, socket) do
    save_category(socket, socket.assigns.action, category_params)
  end

  defp save_category(%{assigns: %{category: category}} = socket, :edit, category_params) do
    case Catalog.update_category(category, category_params) do
      {:ok, _category} ->
        notify_parent(:close_modal)
        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_category(%{assigns: %{category: category}} = socket, :new, category_params) do
    chset = Catalog.change_category(category, category_params)

    case Catalog.insert_category(chset) do
      {:ok, _category} ->
        notify_parent(:close_modal)
        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), msg)
end
