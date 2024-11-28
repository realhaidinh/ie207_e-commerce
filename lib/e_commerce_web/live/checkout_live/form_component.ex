defmodule ECommerceWeb.CheckoutLive.FormComponent do
  alias ECommerce.Orders
  alias ECommerce.Orders.Order
  use ECommerceWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.table id="order-products" rows={@cart.cart_items}>
        <:col :let={item} label="Sản phẩm"><%= item.product.title %></:col>

        <:col :let={item} label="Đơn giá"><%= item.price_when_carted %></:col>

        <:col :let={item} label="Số lượng"><%= item.quantity %></:col>

        <:col :let={item} label="Thành tiền"><%= item.price_when_carted * item.quantity %></:col>
      </.table>

      <.simple_form
        for={@changeset}
        id="order-form"
        phx-target={@myself}
        phx-submit="pay"
      >
        <.input field={@changeset[:buyer_name]} type="text" label="Họ tên" />
        <.input field={@changeset[:buyer_address]} type="text" label="Địa chỉ" />
        <.input field={@changeset[:buyer_phone]} type="text" label="Số điện thoại" />
        <:actions>
          <.button phx-disable-with="..." data-confirm="Xác nhận đặt hàng">Đặt hàng</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:changeset, fn ->
       to_form(Ecto.Changeset.change(%Order{}))
     end)}
  end

  @impl true
  def handle_event("pay", %{"order" => order_params}, socket) do
    cart = socket.assigns.cart

    order = Orders.make_order(cart)
    |> Orders.change_order(order_params)
    |> Orders.complete_order(cart)

    {:noreply, push_patch(socket, to: ~p"/checkout/success/#{order.id}")}
  end
end
