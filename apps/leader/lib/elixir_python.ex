# lib/elixir_python_qrcode.ex
defmodule ElixirPython do
  @moduledoc """
  Documentation for ElixirPython.
  """
  alias Leader.Helper

  # def python_thing() do
  #   call_python(:module, :function, args)
  # end

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
