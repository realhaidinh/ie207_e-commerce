defmodule ECommerce.CatalogTest do
  use ECommerce.DataCase

  alias ECommerce.Catalog

  describe "products" do
    alias ECommerce.Catalog.Product

    import ECommerce.CatalogFixtures

    @invalid_attrs %{description: nil, title: nil, price: nil, stock: nil, slug: nil}

    test "list_products/0 returns all products" do
      product = product_fixture()
      assert Catalog.list_products() == [product]
    end

    test "get_product!/1 returns the product with given id" do
      product = product_fixture()
      assert Catalog.get_product!(product.id) == product
    end

    test "create_product/1 with valid data creates a product" do
      valid_attrs = %{
        description: "some description",
        title: "some title",
        price: 42,
        stock: 42,
        slug: "some slug"
      }

      assert {:ok, %Product{} = product} = Catalog.create_product(valid_attrs)
      assert product.description == "some description"
      assert product.title == "some title"
      assert product.price == 42
      assert product.stock == 42
      assert product.slug == "some slug"
    end

    test "create_product/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Catalog.create_product(@invalid_attrs)
    end

    test "update_product/2 with valid data updates the product" do
      product = product_fixture()

      update_attrs = %{
        description: "some updated description",
        title: "some updated title",
        price: 43,
        stock: 43,
        slug: "some updated slug"
      }

      assert {:ok, %Product{} = product} = Catalog.update_product(product, update_attrs)
      assert product.description == "some updated description"
      assert product.title == "some updated title"
      assert product.price == 43
      assert product.stock == 43
      assert product.slug == "some updated slug"
    end

    test "update_product/2 with invalid data returns error changeset" do
      product = product_fixture()
      assert {:error, %Ecto.Changeset{}} = Catalog.update_product(product, @invalid_attrs)
      assert product == Catalog.get_product!(product.id)
    end

    test "delete_product/1 deletes the product" do
      product = product_fixture()
      assert {:ok, %Product{}} = Catalog.delete_product(product)
      assert_raise Ecto.NoResultsError, fn -> Catalog.get_product!(product.id) end
    end

    test "change_product/1 returns a product changeset" do
      product = product_fixture()
      assert %Ecto.Changeset{} = Catalog.change_product(product)
    end
  end

  describe "categories" do
    alias ECommerce.Catalog.Category

    import ECommerce.CatalogFixtures

    @invalid_attrs %{path: nil, level: nil, title: nil}

    test "list_categories/0 returns all categories" do
      category = category_fixture()
      assert Catalog.list_categories() == [category]
    end

    test "get_category!/1 returns the category with given id" do
      category = category_fixture()
      assert Catalog.get_category!(category.id) == category
    end

    test "create_category/1 with valid data creates a category" do
      valid_attrs = %{path: "some path", level: 42, title: "some title"}

      assert {:ok, %Category{} = category} = Catalog.create_category(valid_attrs)
      assert category.path == "some path"
      assert category.level == 42
      assert category.title == "some title"
    end

    test "create_category/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Catalog.create_category(@invalid_attrs)
    end

    test "update_category/2 with valid data updates the category" do
      category = category_fixture()
      update_attrs = %{path: "some updated path", level: 43, title: "some updated title"}

      assert {:ok, %Category{} = category} = Catalog.update_category(category, update_attrs)
      assert category.path == "some updated path"
      assert category.level == 43
      assert category.title == "some updated title"
    end

    test "update_category/2 with invalid data returns error changeset" do
      category = category_fixture()
      assert {:error, %Ecto.Changeset{}} = Catalog.update_category(category, @invalid_attrs)
      assert category == Catalog.get_category!(category.id)
    end

    test "delete_category/1 deletes the category" do
      category = category_fixture()
      assert {:ok, %Category{}} = Catalog.delete_category(category)
      assert_raise Ecto.NoResultsError, fn -> Catalog.get_category!(category.id) end
    end

    test "change_category/1 returns a category changeset" do
      category = category_fixture()
      assert %Ecto.Changeset{} = Catalog.change_category(category)
    end
  end

  describe "reviews" do
    alias ECommerce.Catalog.Review

    import ECommerce.CatalogFixtures

    @invalid_attrs %{rating: nil, content: nil}

    test "list_reviews/0 returns all reviews" do
      review = review_fixture()
      assert Catalog.list_reviews() == [review]
    end

    test "get_review!/1 returns the review with given id" do
      review = review_fixture()
      assert Catalog.get_review!(review.id) == review
    end

    test "create_review/1 with valid data creates a review" do
      valid_attrs = %{rating: 42, content: "some content"}

      assert {:ok, %Review{} = review} = Catalog.create_review(valid_attrs)
      assert review.rating == 42
      assert review.content == "some content"
    end

    test "create_review/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Catalog.create_review(@invalid_attrs)
    end

    test "update_review/2 with valid data updates the review" do
      review = review_fixture()
      update_attrs = %{rating: 43, content: "some updated content"}

      assert {:ok, %Review{} = review} = Catalog.update_review(review, update_attrs)
      assert review.rating == 43
      assert review.content == "some updated content"
    end

    test "update_review/2 with invalid data returns error changeset" do
      review = review_fixture()
      assert {:error, %Ecto.Changeset{}} = Catalog.update_review(review, @invalid_attrs)
      assert review == Catalog.get_review!(review.id)
    end

    test "delete_review/1 deletes the review" do
      review = review_fixture()
      assert {:ok, %Review{}} = Catalog.delete_review(review)
      assert_raise Ecto.NoResultsError, fn -> Catalog.get_review!(review.id) end
    end

    test "change_review/1 returns a review changeset" do
      review = review_fixture()
      assert %Ecto.Changeset{} = Catalog.change_review(review)
    end
  end
end
