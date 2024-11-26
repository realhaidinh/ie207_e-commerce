defmodule ECommerce.CatalogFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ECommerce.Catalog` context.
  """

  @doc """
  Generate a product.
  """
  def product_fixture(attrs \\ %{}) do
    {:ok, product} =
      attrs
      |> Enum.into(%{
        description: "some description",
        price: 42,
        slug: "some slug",
        stock: 42,
        title: "some title"
      })
      |> ECommerce.Catalog.create_product()

    product
  end

  @doc """
  Generate a category.
  """
  def category_fixture(attrs \\ %{}) do
    {:ok, category} =
      attrs
      |> Enum.into(%{
        level: 42,
        path: "some path",
        title: "some title"
      })
      |> ECommerce.Catalog.create_category()

    category
  end
end
