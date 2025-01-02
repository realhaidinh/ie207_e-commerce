defmodule ECommerceWeb.WebhookController do
  use ECommerceWeb, :controller
  import ECommerce.Payos
  alias ECommerce.Orders

  def payment_confirm(conn, params) do
    success =
      with {:ok, data} <- verify_payment_webhook_data(params),
           "success" <- data["desc"] do
        order = Orders.get_order_by_transaction_id(data["paymentLinkId"])
        {:ok, _} = Orders.update_order(order, %{status: :"Đã thanh toán"})
        true
      else
        _ ->
          false
      end

    json(conn, %{success: success})
  end
end
