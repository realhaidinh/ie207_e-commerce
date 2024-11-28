defmodule ECommerce.Repo.Migrations.CreateReviews do
  use Ecto.Migration

  def change do
    create table(:reviews) do
      add :rating, :integer
      add :content, :string
      add :product_id, references(:products, on_delete: :delete_all)
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:reviews, [:product_id])
    create index(:reviews, [:user_id])
  end
end
