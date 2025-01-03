defmodule ECommerce.Orders.OrderNotifier do
  import Swoosh.Email
  alias ECommerce.Utils.FormatUtil
  alias ECommerce.Mailer
  use ECommerceWeb, :html
  alias ECommerce.Orders.Order
  alias ECommerce.Utils.TimeUtil

  defp deliver(recipient, subject, body) do
    email =
      new()
      |> to(recipient)
      |> from(Mailer.get_sender())
      |> subject(subject)
      |> html_body(
        body
        |> Phoenix.HTML.html_escape()
        |> Phoenix.HTML.safe_to_string()
      )

    Task.Supervisor.start_child(ECommerce.TaskSupervisor, fn ->
      with {:ok, _metadata} <- Mailer.deliver(email) do
        {:ok, email}
      end
    end)
  end

  def deliver_order_paid(%Order{} = order, email) do
    deliver(
      email,
      "Đơn hàng ##{order.id} đã thanh toán thành công",
      order_detail_html(%{order: order, email: email, status: "thanh toán thành công"})
    )
  end

  def deliver_order_shipped(%Order{} = order, email) do
    deliver(
      email,
      "Đơn hàng ##{order.id} đã giao hàng thành công",
      order_detail_html(%{order: order, email: email, status: "giao thành công"})
    )
  end

  defp order_detail_html(assigns) do
    ~H"""
    <p>Xin chào {@email},</p>
    <p>
      Đơn hàng
      <a href={"https://eshopuit.id.vn/users/orders/#{@order.id}"}>
        #{@order.id}
      </a>
      của bạn đã được {@status} ngày {TimeUtil.pretty_print(@order.updated_at)}
    </p>
    <p>THÔNG TIN ĐƠN HÀNG</p>
    <.table id="order-products" rows={@order.line_items}>
      <:col :let={item} label="Sản phẩm">{item.product.title}</:col>

      <:col :let={item} label="Đơn giá">
        <span>
          {ECommerce.Utils.FormatUtil.money_to_vnd(item.price)}
        </span>
      </:col>

      <:col :let={item} label="Số lượng">{item.quantity}</:col>

      <:col :let={item} label="Thành tiền">
        {FormatUtil.money_to_vnd(item.price * item.quantity)}
      </:col>
    </.table>
    <p>Tổng tiền {FormatUtil.money_to_vnd(@order.total_price)}</p>
    <p>Họ tên người nhận: {@order.buyer_name}</p>
    <p>Địa chỉ nhận hàng: {@order.buyer_address}</p>
    <p>Số điện thoại nhận hàng: {@order.buyer_phone}</p>
    <p>Ngày đặt hàng: {TimeUtil.pretty_print_with_time(@order.inserted_at)}</p>
    <p>Phương thức thanh toán: {@order.payment_type}</p>
    """
  end
end
