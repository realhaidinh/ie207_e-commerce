defmodule ECommerce.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products) do
      add :title, :string
      add :description, :string
      add :price, :integer
      add :stock, :integer
      add :sold, :integer
      add :slug, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:products, [:slug])
  end
end
