defmodule LeaderWeb.InputHelpers do
  use Phoenix.HTML

  def orders(form, field, rows) do
    values = Phoenix.HTML.Form.input_value(form, field) || [""]
    id = Phoenix.HTML.Form.input_id(form, field)
    data_index = Enum.count(Phoenix.HTML.Form.input_value(form, :orders))

    content_tag :div,
      id: container_id(id),
      class: "form-group border rounded mt-2 mx-2",
      data_index: data_index do
      values
      |> Enum.with_index()
      |> Enum.map(fn {_value, index} ->
        form_rows(form, id, index, rows)
      end)
    end
  end

  defp form_rows(form, id, index, rows) do
    new_id = id <> "_#{index}"

    content_tag :div,
      class: "form-group rounded border mt-2 mx-2",
      id: new_id do
      [
        Enum.reduce(rows, [], fn row, acc ->
          [acc] ++ [form_row(form, index, row)]
        end),
        content_tag :label,
          onclick: "removeElement('#{new_id}')",
          data: [id: new_id],
          title: "Remove",
          class: "remove-form-field text-primary font-weight-light ml-2" do
          ["Remove"]
        end
      ]
    end
  end

  defp form_row(form, index, [class, columns]) do
    content_tag :div,
      class: class do
      [
        Enum.reduce(columns, [], fn column, acc ->
          [acc] ++ [form_column(form, index, column)]
        end)
      ]
    end
  end

  defp form_column(form, index, [class, column]) do
    content_tag :div,
      class: class do
      [
        Enum.chunk_every(column, 2)
        |> Enum.reduce([], fn input, acc ->
          [acc] ++ [form_input(form, index, input)]
        end)
      ]
    end
  end

  defp form_input(form, index, [field, type]) do
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

    id = Phoenix.HTML.Form.input_id(form, field)

    if type == :checkbox do
      value =
        try do
          Phoenix.HTML.Form.input_value(form, :orders)
          |> Map.values()
          |> Enum.at(index)
          |> Map.get(Atom.to_string(field))
        rescue
          e in ArithmeticError -> ""
        end

      input_opts = [
        name: new_field_name(form, index, field),
        id: id,
        value: value
      ]

      content_tag :div,
        class: "form-check form-check-inline" do
        new_id = id <> "_#{index}"

        [
          apply(Phoenix.HTML.Form, :checkbox, [form, field, input_opts]),
          content_tag :label,
            class: "ml-3" do
            [to_string(field)]
          end
        ]
      end
    else
      value =
        try do
          Phoenix.HTML.Form.input_value(form, :orders)
          |> Map.values()
          |> Enum.at(index)
          |> Map.get(Atom.to_string(field))
        rescue
          e in ArithmeticError -> ""
        end

      content_tag :div do
        input_opts = [
          name: new_field_name(form, index, field),
          id: id,
          value: value
        ]

        [
          content_tag :label do
            [to_string(field)]
          end,
          apply(Phoenix.HTML.Form, type, [form, field, input_opts])
        ]
      end
    end
  end

  def order_add_button(form, field, rows) do
    id = Phoenix.HTML.Form.input_id(form, field)

    content =
      form_rows(form, id, "__name__", rows)
      |> safe_to_string

    data = [
      prototype: content,
      container: container_id(id)
    ]

    content_tag :label,
      onclick: "addElement()",
      title: "Add",
      data: data,
      class: "add-form-field text-primary font-weight-light" do
      ["Add"]
    end
  end

  defp container_id(id), do: id <> "_container"

  defp new_field_name(form, index, field) do
    "lead[orders][#{index}][" <> Atom.to_string(field) <> "]"
  end
end
