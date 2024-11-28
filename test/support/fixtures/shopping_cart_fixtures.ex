defmodule ECommerce.ShoppingCartFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ECommerce.ShoppingCart` context.
  """

  @doc """
  Generate a cart.
  """
  def cart_fixture(attrs \\ %{}) do
    {:ok, cart} =
      attrs
      |> Enum.into(%{})
      |> ECommerce.ShoppingCart.create_cart()

    cart
  end

  @doc """
  Generate a cart_item.
  """
  def cart_item_fixture(attrs \\ %{}) do
    {:ok, cart_item} =
      attrs
      |> Enum.into(%{
        price_when_carted: 42,
        quantity: 42
      })
      |> ECommerce.ShoppingCart.create_cart_item()

    cart_item
  end
end
