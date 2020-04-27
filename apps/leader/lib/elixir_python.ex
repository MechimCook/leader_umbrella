# lib/ElixirPython.ex
defmodule ElixirPython do
  @moduledoc """
  Documentation for ElixirPython.
  """
  alias Leader.Helper

  def create_email(lead) do
    IO.inspect(Enum.into(Map.keys(lead), [], fn x -> Atom.to_string(x) end))
    IO.inspect(Map.values(lead))

    x =
      call_python(:emailer, :email_west, [
        Enum.into(Map.keys(lead), [], fn x -> Atom.to_string(x) end),
        Map.values(lead)
      ])

    IO.inspect(x)
    x
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
