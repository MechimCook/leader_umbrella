defmodule LeaderWeb.InputHelpers do
  use Phoenix.HTML

  def orders(form, field, rows) do
    #
    values = Phoenix.HTML.Form.input_value(form, field) || [""]
    #
    id = Phoenix.HTML.Form.input_id(form, field)

    #

    content_tag :div,
      id: container_id(id),
      class: "form-group border rounded mt-2 mx-2" do
      values
      |> Enum.with_index()
      |> Enum.map(fn {value, index} ->
        new_id = id <> "_#{index}"
        form_rows(form, new_id, rows)
      end)
    end
  end

  defp form_rows(form, id, rows) do
    content_tag :div,
      class: "form-group rounded border mt-2 mx-2",
      id: id do
      [
        Enum.reduce(rows, [], fn row, acc ->
          [acc] ++ [form_row(form, row)]
        end)
      ]
    end
  end

  defp form_row(form, [class, columns]) do
    content_tag :div,
      class: class do
      [
        Enum.reduce(columns, [], fn column, acc ->
          [acc] ++ [form_column(form, column)]
        end)
      ]
    end
  end

  defp form_column(form, [class, column]) do
    content_tag :div,
      class: class do
      [
        Enum.chunk_every(column, 2)
        |> Enum.reduce([], fn input, acc ->
          [acc] ++ [form_input(form, input)]
        end)
      ]
    end
  end

  defp form_input(form, [field, type]) do
    mapping = %{
      "url" => :url_input,
      "email" => :email_input,
      "search" => :search_input,
      "checkbox" => :checkbox,
      "password" => :password_input
    }

    type =
      if Map.get(mapping, type) do
        Map.get(mapping, type)
      else
        :text_input
      end

    values = Phoenix.HTML.Form.input_value(form, field) || [""]
    id = Phoenix.HTML.Form.input_id(form, field)

    if type == :checkbox do
      content_tag :div,
        class: "form-check form-check-inline",
        data: [index: Enum.count(values)] do
        values
        |> Enum.with_index()
        |> Enum.map(fn {value, index} ->
          new_id = id <> "_#{index}"

          input_opts = [
            name: new_field_name(form, field),
            value: value,
            id: new_id,
            class: "mt-2"
          ]

          [
            apply(Phoenix.HTML.Form, type, [form, field, input_opts]),
            content_tag :label,
              class: "ml-3" do
              [to_string(field)]
            end
          ]
        end)
      end
    else
      content_tag :div,
        data: [index: Enum.count(values)] do
        values
        |> Enum.with_index()
        |> Enum.map(fn {value, index} ->
          new_id = id <> "_#{index}"

          input_opts = [
            name: new_field_name(form, field),
            value: value,
            id: new_id
          ]

          [
            content_tag :label do
              [to_string(field)]
            end,
            apply(Phoenix.HTML.Form, type, [form, field, input_opts])
          ]
        end)
      end
    end
  end

  def order_add_button(form, field) do
    # id = Phoenix.HTML.Form.input_id(form, field)
    #
    # content =
    #   form_elements(form, field, "", "__name__")
    #   |> safe_to_string
    #
    # data = [
    #   prototype: content,
    #   container: container_id(id)
    # ]
    #
    # link("Add", to: "#", data: data, class: "add-form-field")
  end

  defp container_id(id), do: id <> "_container"

  defp new_field_name(form, field) do
    "order[" <> Phoenix.HTML.Form.input_name(form, field) <> "[]]"
  end
end
