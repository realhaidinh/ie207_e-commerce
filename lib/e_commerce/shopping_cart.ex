defmodule ECommerce.ShoppingCart do
  @moduledoc """
  The ShoppingCart context.
  """

  import Ecto.Query, warn: false
  alias ECommerce.Catalog
  alias ECommerce.Repo

  alias ECommerce.ShoppingCart.{Cart, CartItem}

  def subscribe(cart_id), do: Phoenix.PubSub.subscribe(ECommerce.PubSub, "cart:#{cart_id}")
  # defp broadcast({:error, _reason} = error, _event), do: error

  def broadcast({:ok, cart} = _message, event) do
    Phoenix.PubSub.broadcast(ECommerce.PubSub, "cart:#{cart.id}", {event, cart})
    {:ok, cart}
  end

  def list_carts do
    Repo.all(Cart)
  end

  def get_cart!(id), do: Repo.get!(Cart, id)

  def get_cart_by_user_id(user_id) do
    Repo.one(
      from(c in Cart,
        where: c.user_id == ^user_id,
        left_join: i in assoc(c, :cart_items),
        left_join: p in assoc(i, :product),
        order_by: [asc: i.inserted_at],
        preload: [cart_items: {i, product: p}]
      )
    )
  end

  def create_cart(user_id) do
    %Cart{user_id: user_id}
    |> Cart.changeset(%{})
    |> Repo.insert()
    |> case do
      {:ok, cart} -> {:ok, reload_cart(cart)}
      {:error, changeset} -> {:error, changeset}
    end
  end

  defp reload_cart(%Cart{} = cart) do
    cart = get_cart_by_user_id(cart.user_id)
    broadcast({:ok, cart}, :cart_updated)
    cart
  end

  def change_cart(%Cart{} = cart, attrs \\ %{}) do
    Cart.changeset(cart, attrs)
  end

  def add_item_to_cart(cart, product_id) when is_nil(cart) or is_nil(product_id) do
    {:error, nil}
  end

  def add_item_to_cart(%Cart{} = cart, product_id) do
    product = Catalog.get_product!(product_id)

    if product.stock > 0 do
      result =
        %CartItem{quantity: 1, price_when_carted: product.price}
        |> CartItem.changeset(%{})
        |> Ecto.Changeset.put_assoc(:cart, cart)
        |> Ecto.Changeset.put_assoc(:product, product)
        |> Repo.insert(
          on_conflict: [inc: [quantity: 1]],
          conflict_target: [:cart_id, :product_id]
        )

      case result do
        {:ok, _} ->
          {:ok, reload_cart(cart)}

        {:error, changeset} ->
          {:error, changeset}
      end
    else
      {:error, nil}
    end
  end

  def remove_item_from_cart(%Cart{} = cart, product_id) do
    {1, _} =
      Repo.delete_all(
        from(i in CartItem,
          where: i.cart_id == ^cart.id,
          where: i.product_id == ^product_id
        )
      )

    {:ok, reload_cart(cart)}
  end

  def update_cart(%Cart{} = cart, attrs) do
    changeset =
      cart
      |> Cart.changeset(attrs)
      |> Ecto.Changeset.cast_assoc(:cart_items, with: &CartItem.changeset/2)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:cart, changeset)
    |> Ecto.Multi.delete_all(:discarded_items, fn %{cart: cart} ->
      from(i in CartItem, where: i.cart_id == ^cart.id and i.quantity == 0)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{cart: cart}} -> {:ok, reload_cart(cart)}
      {:error, :cart, changeset, _changes_so_far} -> {:error, changeset}
    end
  end

  def total_item_price(%CartItem{} = item) do
    item.product.price * item.quantity
  end

  def total_cart_price(%Cart{} = cart) do
    Enum.sum_by(cart.cart_items, &total_item_price(&1))
  end

  def prune_cart_items(%Cart{} = cart) do
    {_, _} = Repo.delete_all(from(i in CartItem, where: i.cart_id == ^cart.id))
    {:ok, reload_cart(cart)}
  end

  def list_cart_items do
    Repo.all(CartItem)
  end

  def create_cart_item(attrs \\ %{}) do
    %CartItem{}
    |> CartItem.changeset(attrs)
    |> Repo.insert()
  end
end
