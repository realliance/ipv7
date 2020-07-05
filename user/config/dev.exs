import Config

config :user, User.Repo,
  username: "postgres",
  password: "postgres",
  database: "users",
  hostname: "localhost"

config :user, :session,
  skb: "A792E2746AD09482E2EE6A296A344638902A42EE8B4BE84AC37EF09515ABB2FD"