# Since configuration is shared in umbrella projects, this file
# should only configure the :leader application itself
# and only for organization purposes. All other config goes to
# the umbrella root.
use Mix.Config

config :leader,
  ecto_repos: [Leader.Repo]

import_config "#{Mix.env()}.exs"
