# lib/ElixirPython.ex
defmodule ElixirPython do
  @moduledoc """
  Documentation for ElixirPython.
  """
  alias Leader.Helper

  def create_email(lead) do
    [order_keys, order_values] =
      Map.get(lead, :orders)
      |> Map.values()
      |> format_order([])

    call_python(:emailer, :email_west, [
      Enum.into(Map.keys(lead), [], fn x -> Atom.to_string(x) end),
      Map.values(lead),
      order_keys,
      order_values
    ])
  end

  defp format_order([order | []], order_values) do
    new_order_values = [Map.values(order)] ++ order_values

    [Map.keys(order), new_order_values]
  end

  defp format_order([order | tail], order_values) do
    new_order_values = [Map.values(order)] ++ order_values

    format_order(tail, new_order_values)
  end

  defp default_instance() do
    # Load all modules in our priv/python directory
    path =
      [:code.priv_dir(:leader), "python"]
      |> Path.join()

    Helper.python_instance(to_charlist(path))
  end

  # wrapper function to call python functions using
  # default python instance
  defp call_python(module, function, args \\ []) do
    default_instance()
    |> Helper.call_python(module, function, args)
  end
end
