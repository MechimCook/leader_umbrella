defmodule Leader.Excel do
  alias Elixlsx.{Workbook, Sheet}
  @west_states ["WY", "CO", "UT", "NV", "ID", "CA", "OR", "WA", "AK", "MT", "FL"]
  @east_states [
    "ME",
    "NH",
    "VT",
    "NY",
    "MA",
    "RI",
    "CT",
    "NJ",
    "PA",
    "DE",
    "MD",
    "DC",
    "MI",
    "OH",
    "IN",
    "IL",
    "WI",
    "WV",
    "VA",
    "NC",
    "TN",
    "KY",
    "SC",
    "GA",
    "AL",
    "MS",
    "FL"
  ]

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

  def excel_generator(leads) do
    # if not found is nil
    # cannot search a nil map

    rows =
      leads
      |> Enum.reduce([], fn lead, rows -> generate_row(lead) ++ rows end)

    sheets =
      leads
      |> Enum.reduce(
        %{west: [], east: [], unsorted: []},
        fn lead, sheets ->
          [sheet_name, row] = sort_leads(lead)

          {_, sheets} =
            Map.get_and_update(sheets, sheet_name, fn old_value ->
              {old_value, old_value ++ row}
            end)

          sheets
        end
      )
      |> create_sheets()

    IO.inspect(sheets)

    %Workbook{sheets: sheets}
    |> Elixlsx.write_to("hello.xlsx")
  end

  defp create_sheets(sheet_rows) do
    [
      %Sheet{name: "East", rows: [@lead_headers] ++ sheet_rows.east},
      %Sheet{name: "West", rows: [@lead_headers] ++ sheet_rows.west},
      %Sheet{name: "Unsorted", rows: [@lead_headers] ++ sheet_rows.unsorted}
    ]
  end

  defp sort_leads(lead) do
    cond do
      Enum.member?(@west_states, lead.state) ->
        [:west, generate_row(lead)]

      Enum.member?(@east_states, lead.state) ->
        [:east, generate_row(lead)]

      true ->
        [:unsorted, generate_row(lead)]
    end
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
end
