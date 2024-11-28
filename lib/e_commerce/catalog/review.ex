defmodule ECommerce.Catalog.Review do
  use Ecto.Schema
  import Ecto.Changeset

  schema "reviews" do
    field :rating, :integer
    field :content, :string
    belongs_to :user, ECommerce.Accounts.User
    belongs_to :product, ECommerce.Catalog.Product

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(review, attrs) do
    review
    |> cast(attrs, [:rating, :content])
    |> validate_required([:rating, :content])
    |> validate_number(:rating, greater_than_or_equal_to: 1, less_than_or_equal_to: 5)
  end
end
