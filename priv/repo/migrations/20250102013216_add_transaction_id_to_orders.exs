defmodule ECommerce.Repo.Migrations.AddTransactionIdToOrders do
  use Ecto.Migration

  def change do
    alter table("orders") do
      add :transaction_id , :string
    end
  end
end
