defmodule ECommerce.ShoppingCart.CartItem do
  alias ECommerce.Catalog
  use Ecto.Schema
  import Ecto.Changeset

  schema "cart_items" do
    field :price_when_carted, :integer
    field :quantity, :integer

    belongs_to :cart, ECommerce.ShoppingCart.Cart
    belongs_to :product, ECommerce.Catalog.Product

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(cart_item, attrs) do
    attrs =
      if cart_item.product_id do
        product = Catalog.get_product!(cart_item.product_id)
        Map.update!(attrs, "quantity", &validate_quantity(&1, product.stock))
      else
        attrs
      end

    cart_item
    |> cast(attrs, [:price_when_carted, :quantity])
    |> validate_required([:price_when_carted, :quantity])
    |> validate_number(:quantity, greater_than_or_equal_to: 0)
  end

  defp validate_quantity("", product_stock) do
    product_stock
  end

  defp validate_quantity(attr_quantity, product_stock) when is_binary(attr_quantity) do
    min(String.to_integer(attr_quantity), product_stock)
  end

  defp validate_quantity(attr_quantity, product_stock) when is_integer(attr_quantity) do
    min(attr_quantity, product_stock)
  end
end
