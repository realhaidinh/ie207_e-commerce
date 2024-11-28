defmodule ECommerceWeb.CartLive.FormComponent do
  alias ECommerce.ShoppingCart
  use ECommerceWeb, :live_component

  alias ECommerce.ShoppingCart

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.simple_form :let={f} for={@changeset} phx-target={@myself} phx-submit="update">
        <.inputs_for :let={item_form} field={f[:cart_items]}>
          <% item = item_form.data %>
          <.input
            class="sm-2 w-50"
            field={item_form[:quantity]}
            type="number"
            label={item.product.title}
          /> <%= ShoppingCart.total_item_price(item) %>
          <.link
            class="rounded-lg bg-zinc-900 text-sm font-semibold leading-6 text-white py-1 px-2"
            phx-click="remove"
            phx-value-product_id={item.product.id}
          >
            Delete
          </.link>
        </.inputs_for>
        
        <:actions>
          <.button>Update cart</.button>
        </:actions>
      </.simple_form>
       <b>Total</b>: <%= ShoppingCart.total_cart_price(@cart) %>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end

  @impl true
  def handle_event("update", %{"cart" => cart_params}, socket) do
    update_cart(socket, cart_params)
  end

  defp update_cart(socket, cart_params) do
    case ShoppingCart.update_cart(socket.assigns.cart, cart_params) do
      {:ok, _cart} ->
        # notify_parent({:updated, cart})

        {:noreply,
         socket
         |> put_flash(:info, "Cart updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  # defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
