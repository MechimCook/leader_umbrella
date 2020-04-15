defmodule Leader.Repo.Migrations.CreateLeads do
  use Ecto.Migration

  def change do
    create table(:leads) do
      add :company, :string
      add :first_name, :string
      add :last_name, :string
      add :email, :string
      add :phone, :string
      add :state, :string
      add :comments, :string
      add :orders, :map
      add :hot, :boolean
      add :catalog, :boolean
      timestamps()
    end

  end
end
