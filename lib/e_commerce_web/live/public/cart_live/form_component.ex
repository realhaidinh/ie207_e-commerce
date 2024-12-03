defmodule ECommerceWeb.Public.CartLive.FormComponent do
  alias ECommerce.ShoppingCart
  use ECommerceWeb, :live_component

  alias ECommerce.ShoppingCart

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.simple_form
        :let={f}
        for={@changeset}
        classess={["grid grid-cols-5 justify-items-center"]}
        phx-target={@myself}
        phx-change="update"
        phx-throttle="200"
      >
      <span class="justify-self-center">Sản phẩm</span>
      <span class="justify-self-center">Đơn giá</span>
      <span class="justify-self-center">Số lượng</span>
      <span class="justify-self-center">Số tiền</span>
      <span class="justify-self-center">Thao tác</span>
        <.inputs_for :let={item_form} field={f[:cart_items]}>
          <% item = item_form.data %>
          <% qty_form = item_form[:quantity] %>
          <label for={qty_form.id}><%= item.product.title%></label>
          <span class="col-start-2"><%= item.product.price %></span>
          <input
            type="number"
            name={qty_form.name}
            id={qty_form.id}
            value={Phoenix.HTML.Form.normalize_value("number", qty_form.value)}
            class="mt-2 block rounded-lg w-1/5 text-zinc-900 focus:ring-0 sm:text-sm sm:leading-6"
          />

          <span class="col-start-4"><%= ShoppingCart.total_item_price(item) %></span>
          <.link
            class="rounded-lg justify-self-center col-start-5 w-10 bg-zinc-900 text-sm font-semibold leading-6 text-white py-1 px-2"
            phx-click="remove"
            phx-value-product_id={item.product.id}
            data-confirm="Bạn có chắc chắn bỏ sản phẩm này"
          >
            Xóa
          </.link>
        </.inputs_for>
      </.simple_form>
      <b>Tổng thanh toán</b>: <%= ShoppingCart.total_cart_price(@cart) %>
      <.link
            class="rounded-lg justify-self-center col-start-5 w-10 bg-zinc-900 text-sm font-semibold leading-6 text-white py-1 px-2"
            patch="/checkout"
          >
            Mua hàng
          </.link>
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
         |> put_flash(:info, "Cập nhật giỏ hàng thành công")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  # defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
