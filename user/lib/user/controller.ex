defmodule User.Controller do

  alias User.{Model.User, Repo}

  def register(params) do
    user = %User{}
    changeset = User.changeset(:register, user, params)
    result = Repo.insert(changeset)
    result
  end
end
