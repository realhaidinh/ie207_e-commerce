defmodule ECommerce.Catalog.Category do
  use Ecto.Schema
  import Ecto.Changeset

  schema "categories" do
    field :path, :string, default: "/"
    field :level, :integer, default: 0
    field :title, :string
    field :slug, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:title, :path, :level, :slug])
    |> validate_required([:title])
  end
end
