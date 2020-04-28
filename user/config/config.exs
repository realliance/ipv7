import Config

config :user, ecto_repos: [User.Repo]
config :user, User.Endpoint,
  port: 4000

import_config "#{Mix.env()}.exs"
