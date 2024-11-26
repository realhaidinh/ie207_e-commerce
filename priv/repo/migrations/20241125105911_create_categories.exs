defmodule ECommerce.Repo.Migrations.CreateCategories do
  use Ecto.Migration

  def change do
    create table(:categories) do
      add :title, :string
      add :path, :string
      add :level, :integer
      add :slug, :string

      timestamps(type: :utc_datetime)
    end

    create index(:categories, [:path])
    create unique_index(:categories, [:slug])
  end
end
