defmodule LeaderWeb.LeadController do
  use LeaderWeb, :controller

  alias Leader.Input
  alias Leader.Input.Lead

  def index(conn, _params) do
    leads = Input.list_leads()
    render(conn, "index.html", leads: leads)
  end

  def new(conn, _params) do
    changeset = Input.change_lead(%Lead{})
    render(conn, "new.html", changeset: changeset)
  end

  def create_emails(conn, _params) do
    Date.utc_today()
    |> Input.create_emails_for_day()

    conn
    |> put_flash(:info, "Generating emails.")
    |> redirect(to: Routes.lead_path(conn, :index))
  end

  def create(conn, %{"lead" => lead_params, "continue" => "true"}) do
    # Add username if logged in
    lead_params =
      case Guardian.Plug.current_resource(conn) do
        nil ->
          lead_params

        user ->
          Map.put(lead_params, "user", user.username)
      end

    case Input.create_lead(lead_params) do
      {:ok, _lead} ->
        conn
        |> put_flash(:info, "Lead created successfully.")
        |> redirect(to: Routes.lead_path(conn, :new))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def create(conn, %{"lead" => lead_params}) do
    lead_params =
      case Guardian.Plug.current_resource(conn) do
        nil ->
          lead_params

        user ->
          Map.put(lead_params, "user", user.username)
      end

    case Input.create_lead(lead_params) do
      {:ok, _lead} ->
        conn
        |> put_flash(:info, "Lead created successfully.")
        |> redirect(to: Routes.lead_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    lead = Input.get_lead!(id)
    changeset = Input.change_lead(lead)
    render(conn, "edit.html", lead: lead, changeset: changeset)
  end

  def update(conn, %{"id" => id, "lead" => lead_params}) do
    lead = Input.get_lead!(id)

    case Input.update_lead(lead, lead_params) do
      {:ok, _lead} ->
        conn
        |> put_flash(:info, "Lead updated successfully.")
        |> redirect(to: Routes.lead_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", lead: lead, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    lead = Input.get_lead!(id)
    {:ok, _lead} = Input.delete_lead(lead)

    conn
    |> put_flash(:info, "Lead deleted successfully.")
    |> redirect(to: Routes.lead_path(conn, :index))
  end
end
