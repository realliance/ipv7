ExUnit.start()
ExUnit.configure seed: elem(:os.timestamp, 2)
Faker.start()
Ecto.Adapters.SQL.Sandbox.mode(User.Repo, :manual)
