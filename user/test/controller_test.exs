defmodule ControllerTest do
  use User.RepoCase

  alias User.{Model.User, Repo, Factory, Controller}
  alias Ecto.Query

  test "register should be successful given valid parameters" do
    response = Controller.register(Factory.params(:user))
    assert match?({:ok, _}, response)
  end

  test "register when successful should insert a new user" do
    params = Factory.params(:user)
    response = Controller.register(params)
    assert match?({:ok, _}, response)
    {:ok, user} = response
    uid = Map.from_struct(user)
            |> Map.get(:id)
    query = Query.from u in User, where: u.id == ^uid
    assert Repo.exists?(query)
  end

  test "login should be successful given valid parameters" do
    params = Factory.params(:user)
    Factory.insert!(:user, params)
    response = Controller.login(params)
    assert match?({true, _}, response)
  end

  test "login should fail if given an invalid email" do
    correct_params = Factory.params(:user)
    wrong_params = Factory.params(:user)
    Factory.insert!(:user, correct_params)
    response = Controller.login(Map.put(correct_params, :email, wrong_params[:email]))
    assert match?({false, _}, response)
  end

  test "login should fail if given an invalid password" do
    correct_params = Factory.params(:user)
    wrong_params = Factory.params(:user)
    Factory.insert!(:user, correct_params)
    response = Controller.login(Map.put(correct_params, :password, wrong_params[:password]))
    assert match?({false, _}, response)
  end

  test "award_points should respond with ok on success" do
    user_params = Factory.params(:user)
    user = Factory.insert!(:user, user_params)
            |> Map.from_struct
    func_params = %{id: user[:id], points: Enum.random(1..255)}
    response = Controller.award_points(func_params)
    assert match?({:ok, _}, response)
  end

  test "award_points should increase the user's points by the given amount" do
    user_params = Factory.params(:user)
    user = Factory.insert!(:user, user_params)
            |> Map.from_struct
    amount = Enum.random(1..255)
    func_params = %{id: user[:id], points: amount}
    {:ok, new_user} = Controller.award_points(func_params)
    user_points = new_user
                    |> Map.from_struct
                    |> Map.get(:points)
    assert user_points == user[:points] + amount
  end

  test "award_points should return :no_user_found when given an invalid id" do
    response = Controller.award_points(%{id: -1, points: 0})
    assert match?({:no_user_found, _}, response)
  end
end