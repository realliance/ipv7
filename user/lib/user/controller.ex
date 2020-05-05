defmodule User.Controller do
  alias User.{Model.User, Repo}

  def register(params) do
    user = %User{}

    User.changeset(:register, user, params)
    |> Repo.insert()
  end

  def login(%{email: _email, password: password} = params) do
    case get_user(params) do
      nil -> {false, nil}
      user -> {Argon2.verify_pass(password, user.password), user}
    end
  end

  def award_points(%{id: _id, points: points} = params) do
    case get_user(params) do
      nil ->
        {:no_user_found, nil}

      user ->
        user
        |> update_user(:award_points, %{points: points + user.points})
    end
  end

  defp update_user(user, changeset, params) do
    User.changeset(changeset, user, params)
    |> Repo.update()
  end

  defp get_user(%{id: id} = _params), do: Repo.get(User, id)

  defp get_user(params), do: Repo.get_by(User, %{email: params[:email]})
end
