import Config

config :user, ecto_repos: [User.Repo]
config :user, User.Endpoint, port: 4000

config :cors_plug,
  origin: ["http://localhost"],
  methods: ["GET", "POST", "PUT"]

import_config "#{Mix.env()}.exs"
