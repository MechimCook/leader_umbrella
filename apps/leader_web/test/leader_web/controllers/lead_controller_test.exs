defmodule LeaderWeb.LeadControllerTest do
  use LeaderWeb.ConnCase

  alias Leader.Input

  @create_attrs %{
    comments: "some comments",
    company: "some company",
    email: "mechim@gmail.com",
    first_name: "some first_name",
    last_name: "some last_name",
    phone: "some phone",
    state: "some state"
  }
  @update_attrs %{
    comments: "some updated comments",
    company: "some updated company",
    email: "mechim@gmail.com",
    first_name: "some updated first_name",
    last_name: "some updated last_name",
    phone: "some updated phone",
    state: "some updated state"
  }
  @invalid_attrs %{
    comments: nil,
    company: nil,
    email: "not an email",
    first_name: nil,
    last_name: nil,
    phone: nil,
    state: nil
  }

  def fixture(:lead) do
    {:ok, lead} = Input.create_lead(@create_attrs)
    lead
  end

  describe "index" do
    test "lists all leads", %{conn: conn} do
      conn = get(conn, Routes.lead_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Leads"
    end
  end

  describe "new lead" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.lead_path(conn, :new))
      assert html_response(conn, 200) =~ "New Lead"
    end
  end

  describe "create lead" do
    setup [:create_lead]

    test "redirects to index when data is valid", %{conn: conn, lead: lead} do
      conn = post(conn, Routes.lead_path(conn, :create), lead: @create_attrs)
      assert redirected_to(conn) == Routes.lead_path(conn, :index)

      conn = get(conn, Routes.lead_path(conn, :edit, lead))
      assert html_response(conn, 200) =~ "Edit Lead"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.lead_path(conn, :create), lead: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Lead"
    end
  end

  describe "edit lead" do
    setup [:create_lead]

    test "renders form for editing chosen lead", %{conn: conn, lead: lead} do
      conn = get(conn, Routes.lead_path(conn, :edit, lead))
      assert html_response(conn, 200) =~ "Edit Lead"
    end
  end

  describe "update lead" do
    setup [:create_lead]

    test "redirects when data is valid", %{conn: conn, lead: lead} do
      conn = put(conn, Routes.lead_path(conn, :update, lead), lead: @update_attrs)
      assert redirected_to(conn) == Routes.lead_path(conn, :index)

      conn = get(conn, Routes.lead_path(conn, :edit, lead))
      assert html_response(conn, 200) =~ "some updated comments"
    end

    test "renders errors when data is invalid", %{conn: conn, lead: lead} do
      conn = put(conn, Routes.lead_path(conn, :update, lead), lead: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Lead"
    end
  end

  describe "delete lead" do
    setup [:create_lead]

    test "deletes chosen lead", %{conn: conn, lead: lead} do
      conn = delete(conn, Routes.lead_path(conn, :delete, lead))
      assert redirected_to(conn) == Routes.lead_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.lead_path(conn, :edit, lead))
      end
    end
  end

  defp create_lead(_) do
    lead = fixture(:lead)
    {:ok, lead: lead}
  end
end
