defmodule User.Controller do

  alias User.{Model.User, Repo}

  def register(params) do
    user = %User{}
    User.changeset(:register, user, params)
      |> Repo.insert
  end

  def login(%{password: password} = params) do
    case get_user(params) do
      nil -> {false, nil}
      user -> {Argon2.verify_pass(password, user.password), user}
    end
  end

  defp get_user(params), do:
    Repo.get_by(User, Map.delete(params, :password))
end
