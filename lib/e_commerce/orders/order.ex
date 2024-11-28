defmodule ECommerce.Orders.Order do
  use Ecto.Schema
  import Ecto.Changeset

  schema "orders" do
    field :total_price, :integer
    field :user_id, :id
    field :buyer_address, :string
    field :buyer_phone, :string
    field :buyer_name, :string
    field :status, :string, default: ""

    has_many :line_items, ECommerce.Orders.LineItem
    has_many :products, through: [:line_items, :product]

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(order, attrs) do
    order
    |> cast(attrs, [:total_price, :user_id, :buyer_address, :buyer_phone, :buyer_name])
    |> validate_required([:total_price, :buyer_address, :buyer_phone, :buyer_name])
  end
end
