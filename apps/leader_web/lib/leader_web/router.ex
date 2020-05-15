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

  pipeline :auth do
    plug Leader.Auth.Pipeline
  end

  pipeline :ensure_auth do
    plug Guardian.Plug.EnsureAuthenticated
  end

  # Maybe logged in scope
  scope "/", LeaderWeb do
    pipe_through [:browser, :auth]
    get "/", AuthController, :index
    post "/", AuthController, :login
    post "/logout", AuthController, :logout
  end

  # Definitely logged in scope
  scope "/secret", LeaderWeb do
    pipe_through [:browser, :auth, :ensure_auth]
    get "/", AuthController, :secret
  end

  scope "/", LeaderWeb do
    pipe_through [:browser, :auth]

    scope "/leads" do
      get "/emails", LeadController, :create_emails
      resources "/", LeadController
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", LeaderWeb do
  #   pipe_through :api
  # end
end
