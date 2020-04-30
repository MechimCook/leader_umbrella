defmodule Leader.Input do
  @moduledoc """
  The Input context.
  """

  import Ecto.Query, warn: false
  alias Leader.Repo
  alias Elixlsx.{Workbook, Sheet}

  alias Leader.Input.Lead

  @west_states ['WY', 'CO', 'UT', 'NV', 'ID', 'CA', 'OR', 'WA', 'AK', 'MT', 'FL']
  import Ecto.Query, only: [from: 2]

  @lead_headers [
    "Company",
    "First_name",
    "Last_name",
    "Phone",
    "Email",
    "Address",
    "City",
    "State",
    "Hot",
    "Catalog",
    "Comments"
  ]

  @products [
    "Bottles",
    "Jars",
    "Roll_ons",
    "Tubes"
  ]

  @materials [
    "Aluminum",
    "Glass",
    "Plastic"
  ]
  @order_headers [
    "Volume",
    "Quantity",
    "Products",
    "Materials"
  ]
  def export() do
    query =
      from lead in Lead,
        select: lead

    query
    |> Repo.all()
    |> excel_generator()
  end

  def excel_generator(leads) do
    # if not found is nil
    # cannot search a nil map

    rows =
      leads
      |> Enum.reduce([], fn lead, rows -> generate_row(lead) ++ rows end)

    IO.inspect(%Workbook{sheets: [%Sheet{name: "leads", rows: [@lead_headers] ++ rows}]})

    %Workbook{sheets: [%Sheet{name: "Leads", rows: [@lead_headers] ++ rows}]}
    |> Elixlsx.write_to("hello.xlsx")
  end

  defp generate_row(lead) do
    row = row(lead)

    if Map.values(lead.orders) != [] && lead.orders != nil do
      [row] ++ generate_orders(Map.values(lead.orders), [])
    end
  end

  defp generate_orders([order | []], order_rows) do
    final_order_rows =
      case order do
        %{
          "Aluminum" => "false",
          "Bottles" => "false",
          "Glass" => "false",
          "Jars" => "false",
          "Plastic" => "false",
          "Quantity" => "",
          "Roll_ons" => "false",
          "Tubes" => "false",
          "Volume" => ""
        } ->
          order_rows

        _ ->
          order_rows ++ order_row(order)
      end

    if final_order_rows != [] do
      [["Potental Orders"]] ++ [@order_headers] ++ [final_order_rows]
    else
      final_order_rows
    end
  end

  defp generate_orders([order | tail], order_rows) do
    case order do
      %{
        "Aluminum" => "false",
        "Bottles" => "false",
        "Glass" => "false",
        "Jars" => "false",
        "Plastic" => "false",
        "Quantity" => "",
        "Roll_ons" => "false",
        "Tubes" => "false",
        "Volume" => ""
      } ->
        generate_orders(tail, order_rows)

      _ ->
        generate_orders(tail, order_rows ++ order_row(order))
    end
  end

  defp order_row(order) do
    products =
      @products
      |> Enum.reduce(fn product, products ->
        if Map.get(order, product) != "false" do
          IO.inspect(Map.get(order, product))
          product <> ", " <> products
        else
          products
        end
      end)

    materials =
      @materials
      |> Enum.reduce(fn material, materials ->
        if Map.get(order, material) != "false" do
          material <> ", " <> materials
        else
          materials
        end
      end)

    [Map.get(order, "Volume"), Map.get(order, "Quantity"), products, materials]
  end

  defp row(lead) do
    [
      lead.company,
      lead.first_name,
      lead.last_name,
      lead.phone,
      lead.email,
      lead.address,
      lead.city,
      lead.state,
      lead.hot,
      lead.catalog,
      lead.comments
    ]
    |> Enum.map(fn x ->
      case x do
        nil ->
          ""

        false ->
          "No"

        _ ->
          x
      end
    end)
  end

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
