defmodule ECommerceWeb.WebhookController do
  use ECommerceWeb, :controller
  import ECommerce.Payos
  alias ECommerce.Orders.OrderNotifier
  alias ECommerce.Orders

  def payment_confirm(conn, params) do
    success =
      with {:ok, data} <- verify_payment_webhook_data(params),
           "success" <- data["desc"],
           order <- Orders.get_order_by_transaction_id(data["paymentLinkId"]),
           {:ok, order} <- Orders.update_order(order, %{status: :"Đã thanh toán"}) do
        OrderNotifier.deliver_order_paid(order, order.user.email)
        true
      else
        _ ->
          false
      end

    json(conn, %{success: success})
  end
end
