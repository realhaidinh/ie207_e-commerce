defmodule ECommerce.Orders.OrderNotifierTest do
  use ExUnit.Case, async: true
  import Swoosh.TestAssertions

  alias ECommerce.Orders.OrderNotifier

  test "deliver_create_order/1" do
    user = %{name: "Alice", email: "alice@example.com"}

    OrderNotifier.deliver_create_order(user)

    assert_email_sent(
      subject: "Welcome to Phoenix, Alice!",
      to: {"Alice", "alice@example.com"},
      text_body: ~r/Hello, Alice/
    )
  end

  test "deliver_order_confirm/1" do
    user = %{name: "Alice", email: "alice@example.com"}

    OrderNotifier.deliver_order_confirm(user)

    assert_email_sent(
      subject: "Welcome to Phoenix, Alice!",
      to: {"Alice", "alice@example.com"},
      text_body: ~r/Hello, Alice/
    )
  end
end
