defmodule ECommerce.OrdersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ECommerce.Orders` context.
  """

  @doc """
  Generate a order.
  """
  def order_fixture(attrs \\ %{}) do
    {:ok, order} =
      attrs
      |> Enum.into(%{
        total_price: 42
      })
      |> ECommerce.Orders.create_order()

    order
  end

  @doc """
  Generate a line_item.
  """
  def line_item_fixture(attrs \\ %{}) do
    {:ok, line_item} =
      attrs
      |> Enum.into(%{
        price: 42,
        quantity: 42
      })
      |> ECommerce.Orders.create_line_item()

    line_item
  end
end
