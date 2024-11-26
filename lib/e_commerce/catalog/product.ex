defmodule ECommerce.Catalog.Product do
  use Ecto.Schema
  import Ecto.Changeset
  alias ECommerce.Catalog.Category

  schema "products" do
    field :description, :string
    field :title, :string
    field :price, :integer
    field :stock, :integer
    field :sold, :integer, default: 0
    field :slug, :string

    many_to_many :categories, Category,
      join_through: "product_categories",
      on_replace: :delete,
      preload_order: [asc: :level]

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [:title, :description, :price, :stock, :slug])
    |> validate_required([:title, :description, :price, :stock, :slug])
  end
end
