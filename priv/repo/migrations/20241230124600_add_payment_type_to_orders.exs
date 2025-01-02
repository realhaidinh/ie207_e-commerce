defmodule ECommerce.Repo.Migrations.AddPaymentTypeToOrders do
  use Ecto.Migration

  def change do
    alter table("orders") do
      add :payment_type, :string
    end
  end
end
