defmodule ECommerceWeb.Public.CheckoutLive.Success do
  alias ECommerce.Orders
  use ECommerceWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        Đơn hàng {@order.id} {get_order_status(@status)}
      </.header>

      <.table
        id="order-products"
        rows={@order.line_items}
        row_click={fn item -> JS.navigate(~p"/products/#{item.product.id}") end}
      >
        <:col :let={item} label="Sản phẩm">{item.product.title}</:col>

        <:col :let={item} label="Đơn giá">{item.price}</:col>

        <:col :let={item} label="Số lượng">{item.quantity}</:col>

        <:col :let={item} label="Thành tiền">{item.price * item.quantity}</:col>
      </.table>

      <h1>Tổng tiền {@order.total_price}</h1>

      <p>Họ tên người nhận: {@order.buyer_name}</p>

      <p>Địa chỉ nhận hàng: {@order.buyer_address}</p>

      <p>Số điện thoại nhận hàng: {@order.buyer_phone}</p>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket}
  end

  defp get_order_status(:pending), do: "đang thanh toán"
  defp get_order_status(:paid), do: "đã thanh toán"
  defp get_order_status(:processing), do: "đang xử lý"
  defp get_order_status(:cancelled), do: "đã hủy"

  @impl true
  def handle_params(params, _uri, socket) do
    %{current_user: %{id: user_id}} = socket.assigns
    order = Orders.get_user_order_by_transaction_id!(user_id, params["id"])
    socket = assign(socket, :order, order)
    if order.payment_type == :"Thanh toán khi nhận hàng" do
      {:noreply, assign(socket, :status, :pending)}
    else
      case params["status"] do
        "PAID" ->
          {:noreply, assign(socket, :status, :paid)}

        "PENDING" ->
          {:noreply, assign(socket, :status, :pending)}

        "PROCESSING" ->
          {:noreply, assign(socket, :status, :processing)}

        "CANCELLED" ->
          {:noreply, assign(socket, :status, :canclled)}
      end
    end
  end
end
