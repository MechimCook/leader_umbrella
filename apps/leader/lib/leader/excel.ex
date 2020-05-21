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
    ["Entered By", bold: true, align_horizontal: :center],
    ["Company", bold: true, align_horizontal: :center],
    ["First Name", bold: true, align_horizontal: :center],
    ["Last Name", bold: true, align_horizontal: :center],
    ["Phone", bold: true, align_horizontal: :center],
    ["Email", bold: true, align_horizontal: :center],
    ["Address", bold: true, align_horizontal: :center],
    ["City", bold: true, align_horizontal: :center],
    ["State", bold: true, align_horizontal: :center],
    ["Hot", bold: true, align_horizontal: :center],
    ["Catalog", bold: true, align_horizontal: :center],
    ["Comments", bold: true, align_horizontal: :center]
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
    ["Volume", bold: true, align_horizontal: :center],
    ["Quantity", bold: true, align_horizontal: :center],
    ["Products", bold: true, align_horizontal: :center],
    ["Materials", bold: true, align_horizontal: :center]
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
              {old_value,
               old_value ++
                 [{order_start..order_end, collapsed: true}]}
            end)

          [sheets, order_groups]
        end
      )
      |> create_sheets()

    today = Date.utc_today()

    %Workbook{sheets: sheets}
    |> Elixlsx.write_to(
      "leads" <>
        "_" <>
        Integer.to_string(today.year) <>
        "_" <> Integer.to_string(today.month) <> "_" <> Integer.to_string(today.day) <> ".xlsx"
    )
  end

  defp create_sheets([sheet_rows, order_groups]) do
    IO.inspect(order_groups)

    widths = %{
      1 => 20,
      2 => 20,
      3 => 25,
      4 => 25,
      5 => 16,
      6 => 25,
      7 => 25,
      8 => 20,
      9 => 10,
      10 => 10,
      11 => 10,
      12 => 25
    }

    [
      %Sheet{
        col_widths: widths,
        name: "East",
        rows: [@lead_headers] ++ sheet_rows.east,
        group_rows: order_groups.east
      },
      %Sheet{
        col_widths: widths,
        name: "West",
        rows: [@lead_headers] ++ sheet_rows.west,
        group_rows: order_groups.west
      },
      %Sheet{
        col_widths: widths,
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
      [[["Potential Orders", bold: true, color: "#0023ad", align_horizontal: :center]]] ++
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

    [
      [Map.get(order, "Volume"), align_horizontal: :center],
      [Map.get(order, "Quantity"), align_horizontal: :center],
      [products, align_horizontal: :center],
      [materials, align_horizontal: :center]
    ]
  end

  defp row(lead) do
    [
      [lead.user || "Unkonwn", align_horizontal: :center],
      [lead.company, align_horizontal: :center],
      [lead.first_name, align_horizontal: :center],
      [lead.last_name, align_horizontal: :center],
      [String.to_integer(lead.phone), num_format: "(###) ### ####", align_horizontal: :center],
      [lead.email, align_horizontal: :center],
      [lead.address, align_horizontal: :center],
      [lead.city, align_horizontal: :center],
      [lead.state, align_horizontal: :center],
      [lead.hot, align_horizontal: :center],
      [lead.catalog, align_horizontal: :center],
      [lead.comments, align_horizontal: :center]
    ]
    |> Enum.map(fn x ->
      case x do
        nil ->
          "None"

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
