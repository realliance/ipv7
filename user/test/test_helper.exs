ExUnit.start()
ExUnit.configure seed: elem(:os.timestamp, 2)
Ffaker.Seed.reset()
Ecto.Adapters.SQL.Sandbox.mode(User.Repo, :manual)
