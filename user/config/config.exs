import Config

config :user, User.Endpoint,
  port: 4000

import_config "#{Mix.env()}.exs"
