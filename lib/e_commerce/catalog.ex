defmodule ECommerce.Catalog do
  @moduledoc """
  The Catalog context.
  """

  import Ecto.Query, warn: false
  alias ECommerce.Repo
  alias ECommerce.Catalog.{Category, ProductImage, Product, Review}

  @doc """
  Returns the list of products.

  ## Examples

      iex> list_products()
      [%Product{}, ...]

  """
  def list_products do
    Repo.all(
      from p in Product,
        left_join: r in assoc(p, :reviews),
        select_merge: %{rating: coalesce(avg(r.rating), 0.0)},
        group_by: [p.id]
    )
  end

  def list_products_by_category(id) do
    Repo.all(
      from p in Product,
        left_join: r in assoc(p, :reviews),
        left_join: c in "product_categories",
        on: c.product_id == p.id,
        where: c.category_id == ^id,
        select_merge: %{rating: coalesce(avg(r.rating), 0.0)},
        group_by: [p.id]
    )
  end

  def search_product(opts) do
    _page_no = Map.get(opts, "page", 1)
    keyword = "%" <> Map.get(opts, "keyword", "") <> "%"

    Repo.all(
      from p in Product,
        where: like(p.title, ^keyword),
        left_join: r in assoc(p, :reviews),
        select_merge: %{rating: coalesce(avg(r.rating), 0.0)},
        group_by: [p.id],
        limit: 5
    )
  end

  @doc """
  Gets a single product.

  Raises `Ecto.NoResultsError` if the Product does not exist.

  ## Examples

      iex> get_product!(123)
      %Product{}

      iex> get_product!(456)
      ** (Ecto.NoResultsError)

  """
  def get_product!(id) do
    Repo.one!(
      from p in Product,
        where: p.id == ^id,
        left_join: r in assoc(p, :reviews),
        select_merge: %{
          rating: coalesce(avg(r.rating), 0.0),
          rating_count: coalesce(count(r.rating), 0)
        },
        preload: [:categories]
    )
  end

  def get_product(id, opts) do
    query =
      from(p in Product,
        where: p.id == ^id
      )

    Enum.reduce(opts, query, fn opt, acc -> preload_assoc(acc, opt) end)
    |> Repo.one()
  end

  defp preload_assoc(query, :categories), do: query |> preload(:categories)
  defp preload_assoc(query, :images), do: query |> preload(:images)

  defp preload_assoc(query, :cover) do
    from(p in query,
      left_join: i in assoc(p, :images),
      select_merge: %{cover: i.url},
      limit: 1
    )
  end

  defp preload_assoc(query, :reviews) do
    from(p in query,
      left_join: r in assoc(p, :reviews),
      select_merge: %{
        rating: coalesce(avg(r.rating), 0.0),
        rating_count: coalesce(count(r.rating), 0)
      },
      group_by: [p.id]
    )
  end

  @doc """
  Creates a product.

  ## Examples

      iex> create_product(%{field: value})
      {:ok, %Product{}}

      iex> create_product(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_product(attrs \\ %{}) do
    %Product{}
    |> change_product(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a product.

  ## Examples

      iex> update_product(product, %{field: new_value})
      {:ok, %Product{}}

      iex> update_product(product, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_product(%Product{} = product, attrs) do
    product
    |> change_product(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a product.

  ## Examples

      iex> delete_product(product)
      {:ok, %Product{}}

      iex> delete_product(product)
      {:error, %Ecto.Changeset{}}

  """
  def delete_product(%Product{} = product) do
    Repo.delete(product)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking product changes.

  ## Examples

      iex> change_product(product)
      %Ecto.Changeset{data: %Product{}}

  """
  def change_product(%Product{} = product, attrs \\ %{}) do
    attrs = Map.put(attrs, "slug", slugify(product.title))
    images = build_product_images(attrs)
    categories = build_product_categories(attrs)

    product
    |> Product.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:categories, categories)
    |> Ecto.Changeset.put_assoc(:images, images)
  end

  defp build_product_images(attrs) do
    attrs
    |> Map.get("uploaded_files", [])
    |> Enum.map(&%ProductImage{url: &1})
  end

  defp build_product_categories(attrs) do
    category = get_category(attrs["category_id"])

    parent_category_ids =
      case category do
        nil -> []
        _ -> String.split(category.path, ~r/\//, trim: true)
      end

    [category | list_categories_by_ids(parent_category_ids)]
  end

  @doc """
  Returns the list of categories.

  ## Examples

      iex> list_categories()
      [%Category{}, ...]

  """
  def list_categories do
    Repo.all(Category)
  end

  def list_categories_by_ids(category_ids) do
    Repo.all(from c in Category, where: c.id in ^category_ids)
  end

  @doc """
  Gets a single category.

  Raises `Ecto.NoResultsError` if the Category does not exist.

  ## Examples

      iex> get_category!(123)
      %Category{}

      iex> get_category!(456)
      ** (Ecto.NoResultsError)

  """
  def get_category!(id), do: Repo.get!(Category, id)
  def get_category(id), do: Repo.get(Category, id)

  def get_category_with_product_count(id) do
    Repo.one(
      from c in Category,
        where: c.id == ^id,
        left_join: pc in "product_categories",
        on: pc.category_id == c.id,
        select_merge: %{product_count: coalesce(count(pc.category_id), 0)},
        group_by: [c.id]
    )
  end

  def list_root_categories() do
    Repo.all(
      from c in Category,
        where: c.level == 0,
        left_join: pc in "product_categories",
        on: pc.category_id == c.id,
        select_merge: %{product_count: coalesce(count(pc.category_id), 0)},
        group_by: [c.id]
    )
  end

  def get_subcategory_path(%Category{} = category) do
    "#{category.path}#{category.id}/"
  end

  def get_subcategories(%Category{} = category) do
    subpath = get_subcategory_path(category)

    Repo.all(
      from c in Category,
        where: c.path == ^subpath,
        left_join: pc in "product_categories",
        on: pc.category_id == c.id,
        select_merge: %{product_count: coalesce(count(pc.category_id), 0)},
        group_by: [c.id]
    )
  end

  @doc """
  Creates a category.

  ## Examples

      iex> create_category(%{field: value})
      {:ok, %Category{}}

      iex> create_category(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_category(attrs \\ %{}) do
    %Category{}
    |> change_category(attrs)
    |> Repo.insert()
  end

  def insert_category(%Ecto.Changeset{} = chset), do: Repo.insert(chset)

  @doc """
  Updates a category.

  ## Examples

      iex> update_category(category, %{field: new_value})
      {:ok, %Category{}}

      iex> update_category(category, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_category(%Category{} = category, attrs) do
    category
    |> change_category(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a category.

  ## Examples

      iex> delete_category(category)
      {:ok, %Category{}}

      iex> delete_category(category)
      {:error, %Ecto.Changeset{}}

  """
  def delete_category(%Category{} = category) do
    subpath = get_subcategory_path(category) <> "%"

    Repo.delete_all(
      from c in Category,
        where: c.id == ^category.id or like(c.path, ^subpath)
    )
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking category changes.

  ## Examples

      iex> change_category(category)
      %Ecto.Changeset{data: %Category{}}

  """
  def change_category(%Category{} = category, attrs \\ %{}) do
    attrs = Map.put(attrs, "slug", slugify(category.title))
    Category.changeset(category, attrs)
  end

  alias ECommerce.Catalog.Review

  @doc """
  Returns the list of reviews.

  ## Examples

      iex> list_reviews()
      [%Review{}, ...]

  """
  def list_reviews do
    Repo.all(Review)
  end

  def list_reviews_by_product(product_id) do
    Repo.all(
      from r in Review,
        where: r.product_id == ^product_id,
        left_join: u in assoc(r, :user),
        order_by: [desc: :inserted_at],
        preload: [user: u]
    )
  end

  @doc """
  Gets a single review.

  Raises `Ecto.NoResultsError` if the Review does not exist.

  ## Examples

      iex> get_review!(123)
      %Review{}

      iex> get_review!(456)
      ** (Ecto.NoResultsError)

  """
  def get_review!(id), do: Repo.get!(Review, id)

  @doc """
  Creates a review.

  ## Examples

      iex> create_review(%{field: value})
      {:ok, %Review{}}

      iex> create_review(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_review(attrs \\ %{}) do
    %Review{}
    |> Review.changeset(attrs)
    |> Repo.insert()
  end

  def create_review(user_id, product_id, attrs \\ %{}) do
    %Review{
      user_id: user_id,
      product_id: product_id
    }
    |> Review.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a review.

  ## Examples

      iex> update_review(review, %{field: new_value})
      {:ok, %Review{}}

      iex> update_review(review, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_review(%Review{} = review, attrs) do
    review
    |> Review.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a review.

  ## Examples

      iex> delete_review(review)
      {:ok, %Review{}}

      iex> delete_review(review)
      {:error, %Ecto.Changeset{}}

  """
  def delete_review(%Review{} = review) do
    Repo.delete(review)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking review changes.

  ## Examples

      iex> change_review(review)
      %Ecto.Changeset{data: %Review{}}

  """
  def change_review(%Review{} = review, attrs \\ %{}) do
    Review.changeset(review, attrs)
  end

  def slugify(nil), do: nil

  def slugify(text) do
    text
    |> String.downcase()
    |> String.trim()
    |> String.normalize(:nfkd)
    |> String.replace(~r/[^a-z0-9\s-]/u, "")
    |> String.replace(~r/[\s-]+/, "-", global: true)
  end
end
