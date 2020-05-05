defmodule User.RepoCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias User.Repo

      import Ecto
      import Ecto.Query
      import User.RepoCase
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(User.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(User.Repo, {:shared, self()})
    end

    :ok
  end
end
