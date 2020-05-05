import Config

config :user, User.Repo,
  username: "postgres",
  password: "postgres",
  database: "users",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
