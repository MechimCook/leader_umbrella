defmodule LeaderWeb.Router do
  use LeaderWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", LeaderWeb do
    pipe_through :browser

    scope "/leads" do
      get "/emails", LeadController, :create_emails
      resources "/", LeadController
    end

    resources "/leads", LeadController
    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", LeaderWeb do
  #   pipe_through :api
  # end
end
