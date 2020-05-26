defmodule LeaderWeb.PageControllerTest do
  use LeaderWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "No one is logged in"
  end
end
