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

      timestamps()
    end

  end
end
