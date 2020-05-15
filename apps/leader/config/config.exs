# Since configuration is shared in umbrella projects, this file
# should only configure the :leader application itself
# and only for organization purposes. All other config goes to
# the umbrella root.
use Mix.Config

config :leader, Leader.Auth.Guardian,
  # Name of your app/company/product
  issuer: "leader",
  # Replace this with the output of the mix command
  secret_key: "tP1e0l44uibBBIoNfBvS2KsgNmCwjc6RrmWLmCMGWyOWLVE4P5P1uDKvy2jc9gj5"

config :leader,
  ecto_repos: [Leader.Repo]

import_config "#{Mix.env()}.exs"
