defmodule ECommerceWeb.Public.CartLive.FormComponent do
  alias ECommerce.ShoppingCart
  use ECommerceWeb, :live_component

  alias ECommerce.ShoppingCart

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="grid grid-cols-5 mt-8">
        <span class="justify-self-center col-start-1">Sản phẩm</span>
        <span class="justify-self-center">Đơn giá</span>
        <span class="justify-self-center">Số lượng</span>
        <span class="justify-self-center">Số tiền</span>
        <span class="justify-self-center">Thao tác</span>
      </div>
      <.simple_form
        :let={f}
        for={ShoppingCart.change_cart(@cart)}
        classes={["grid grid-cols-5 justify-items-center"]}
        phx-target={@myself}
        phx-change="update"
        phx-throttle="200"
      >
        <.inputs_for :let={item_form} field={f[:cart_items]}>
          <% item = item_form.data %>
          <% qty_attr = item_form[:quantity] %>
          <label
            for={qty_attr.id}
            class="hover:cursor-pointer"
            phx-click={JS.navigate("/products/#{item.product.id}")}
          >
            <%= item.product.title %>
          </label>
          <span id={"item-#{item.id}-price"} class="col-start-2" phx-hook="CurrencyFormat">
            <%= item.product.price %>
          </span>
          <input
            type="number"
            name={qty_attr.name}
            id={qty_attr.id}
            value={Phoenix.HTML.Form.normalize_value("number", qty_attr.value)}
            class="mt-2 block rounded-lg w-1/5 text-zinc-900 focus:ring-0 sm:text-sm sm:leading-6"
          />
          <span class="col-start-4" id={"item-#{item.id}-total-price"} phx-hook="CurrencyFormat">
            <%= ShoppingCart.total_item_price(item) %>
          </span>
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
      <b>Tổng thanh toán:</b>
      <span id="total_price" phx-hook="CurrencyFormat">
        <%= ShoppingCart.total_cart_price(@cart) %>
      </span>
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
        {:noreply, put_flash(socket, :info, "Cập nhật giỏ hàng thành công")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
