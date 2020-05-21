defmodule Leader.Excel do
  alias Elixlsx.{Workbook, Sheet}
  @west_states ["WY", "CO", "UT", "NV", "ID", "CA", "OR", "WA", "AK", "MT"]
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
    ["Entered By", bold: true],
    ["Company", bold: true],
    ["First Name", bold: true],
    ["Last Name", bold: true],
    ["Phone", bold: true],
    ["Email", bold: true],
    ["Address", bold: true],
    ["City", bold: true],
    ["State", bold: true],
    ["Hot", bold: true],
    ["Catalog", bold: true],
    ["Comments", bold: true]
  ]

  @products [
    "Bottles",
    "Jars",
    "Roll ons",
    "Tubes"
  ]

  @materials [
    "Aluminum",
    "Glass",
    "Plastic"
  ]
  @order_headers [
    ["Volume", bold: true],
    ["Quantity", bold: true],
    ["Products", bold: true],
    ["Materials", bold: true]
  ]

  def excel_generator(leads) do
    # if not found is nil
    # cannot search a nil map

    sheets =
      leads
      |> Enum.reduce(
        [%{west: [], east: [], unsorted: []}, %{west: [], east: [], unsorted: []}],
        fn lead, [sheets, order_groups] ->
          [sheet_name, row] = sort_leads(lead)

          order_start = Enum.count(Map.get(sheets, sheet_name)) + 4

          {_, sheets} =
            Map.get_and_update(sheets, sheet_name, fn old_value ->
              {old_value, old_value ++ row}
            end)

          order_end = Enum.count(Map.get(sheets, sheet_name)) + 1

          {_, order_groups} =
            Map.get_and_update(order_groups, sheet_name, fn old_value ->
              {old_value, old_value ++ [{order_start..order_end, collapsed: true}]}
            end)

          IO.inspect(order_groups)

          [sheets, order_groups]
        end
      )
      |> create_sheets()

    %Workbook{sheets: sheets}
    |> Elixlsx.write_to("hello.xlsx")
  end

  defp create_sheets([sheet_rows, order_groups]) do
    IO.inspect(order_groups)

    [
      %Sheet{
        name: "East",
        rows: [@lead_headers] ++ sheet_rows.east,
        group_rows: order_groups.east
      },
      %Sheet{
        name: "West",
        rows: [@lead_headers] ++ sheet_rows.west,
        group_rows: order_groups.west
      },
      %Sheet{
        name: "Unsorted",
        rows: [@lead_headers] ++ sheet_rows.unsorted,
        group_rows: order_groups.unsorted
      }
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
          "Products" => [],
          "Materials" => [],
          "Quantity" => "",
          "Volume" => ""
        } ->
          order_rows

        _ ->
          order_rows ++ order_row(order)
      end

    if final_order_rows != [] do
      [[["Potental Orders", bold: true, color: "#0023ad"]]] ++
        [@order_headers] ++ [final_order_rows]
    else
      final_order_rows
    end
  end

  defp generate_orders([order | tail], order_rows) do
    case order do
      %{
        "Products" => [],
        "Materials" => [],
        "Quantity" => "",
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
      lead.user || "anon",
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
          "No"

        false ->
          "No"

        true ->
          "Yes"

        _ ->
          x
      end
    end)
  end
end
