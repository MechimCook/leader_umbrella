defmodule Leader.Input do
  @moduledoc """
  The Input context.
  """

  import Ecto.Query, warn: false
  alias Leader.Repo

  alias Leader.Input.Lead

  @west_states ['WY', 'CO', 'UT', 'NV', 'ID', 'CA', 'OR', 'WA', 'AK', 'MT', 'FL']
  import Ecto.Query, only: [from: 2]

  def create_emails_for_day(date) do
    # date should be a day
    query =
      from lead in Lead,
        where: fragment("?::date", lead.inserted_at) >= ^date,
        select: lead

    query
    |> Repo.all()
    |> Enum.reject(fn lead ->
      Enum.member?(@west_states, lead.state) && lead.email == nil
    end)
    |> Enum.each(fn lead ->
      Map.from_struct(lead)
      |> ElixirPython.create_email()
    end)
  end

  @doc """
  Returns the list of leads.

  ## Examples

      iex> list_leads()
      [%Lead{}, ...]

  """
  def list_leads do
    Repo.all(Lead)
  end

  @doc """
  Gets a single lead.

  Raises `Ecto.NoResultsError` if the Lead does not exist.

  ## Examples

      iex> get_lead!(123)
      %Lead{}

      iex> get_lead!(456)
      ** (Ecto.NoResultsError)

  """
  def get_lead!(id), do: Repo.get!(Lead, id)

  @doc """
  Creates a lead.

  ## Examples

      iex> create_lead(%{field: value})
      {:ok, %Lead{}}

      iex> create_lead(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_lead(attrs \\ %{}) do
    %Lead{}
    |> Lead.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a lead.

  ## Examples

      iex> update_lead(lead, %{field: new_value})
      {:ok, %Lead{}}

      iex> update_lead(lead, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_lead(%Lead{} = lead, attrs) do
    lead
    |> Lead.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a lead.

  ## Examples

      iex> delete_lead(lead)
      {:ok, %Lead{}}

      iex> delete_lead(lead)
      {:error, %Ecto.Changeset{}}

  """
  def delete_lead(%Lead{} = lead) do
    Repo.delete(lead)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking lead changes.

  ## Examples

      iex> change_lead(lead)
      %Ecto.Changeset{source: %Lead{}}

  """
  def change_lead(%Lead{} = lead) do
    Lead.changeset(lead, %{})
  end
end
