defmodule Leader.Input.Lead do
  use Ecto.Schema
  import Ecto.Changeset

  schema "leads" do
    field :comments, :string
    field :company, :string
    field :email, :string
    field :first_name, :string
    field :last_name, :string
    field :phone, :string
    field :state, :string

    timestamps()
  end

  @doc false
  def changeset(lead, attrs) do
    lead
    |> cast(attrs, [:company, :first_name, :last_name, :email, :phone, :state, :comments])
    |> validate_format(:email, ~r/@/)
  end
end
