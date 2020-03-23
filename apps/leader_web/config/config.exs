# Since configuration is shared in umbrella projects, this file
# should only configure the :leader_web application itself
# and only for organization purposes. All other config goes to
# the umbrella root.
use Mix.Config

# General application configuration
config :leader_web,
  ecto_repos: [Leader.Repo],
  generators: [context_app: :leader]

# Configures the endpoint
config :leader_web, LeaderWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "I8zqMmKIu2wO8y+hAf456mCIW9+sJDXYqFtD6TWtHSQp5cslDwagmUOzMaqb+mLT",
  render_errors: [view: LeaderWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: LeaderWeb.PubSub, adapter: Phoenix.PubSub.PG2]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
