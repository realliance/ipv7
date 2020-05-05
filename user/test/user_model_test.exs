defmodule UserModelTest do
  use User.RepoCase

  alias User.{Factory, Model.User}

  test "registering a user should be valid with an email, name, and password" do
    changeset = User.changeset(:register, %User{}, Factory.params(:user))
    assert changeset.valid?
  end

  test "registering a user should be invalid with a missing email" do
    changeset = User.changeset(:register, %User{}, Factory.lacking_param(:user, :email))
    assert not changeset.valid?
  end

  test "registering a user should be invalid with a missing name" do
    changeset = User.changeset(:register, %User{}, Factory.lacking_param(:user, :name))
    assert not changeset.valid?
  end

  test "registering a user should be invalid with a missing password" do
    changeset = User.changeset(:register, %User{}, Factory.lacking_param(:user, :password))
    assert not changeset.valid?
  end

  test "registering a user should hash the password" do
    params = Factory.params(:user)
    changeset = User.changeset(:register, %User{}, params)
    assert params.password != changeset.changes[:password]
  end

  test "registering a user should produce a valid argon2 hash for the password" do
    params = Factory.params(:user)
    changeset = User.changeset(:register, %User{}, params)
    assert Argon2.verify_pass(params.password, changeset.changes[:password])
  end

  test "registering a user should strip out any attempts to register with points" do
    params = Factory.params(:user, %{points: 5})
    changeset = User.changeset(:register, %User{}, params)
    assert not Map.has_key?(changeset.changes, :points)
  end

  test "updating a user should strip out any attempts to update points" do
    params = Factory.params(:user, %{points: 5})
    changeset = User.changeset(:update, %User{}, params)
    assert not Map.has_key?(changeset.changes, :points)
  end

  test "award_points changeset should allow only points defined" do
    params = Factory.params(:user, %{points: 5})
    changeset = User.changeset(:award_points, %User{}, params)
    assert Map.has_key?(changeset.changes, :points)
    assert not Map.has_key?(changeset.changes, :name)
    assert not Map.has_key?(changeset.changes, :email)
    assert not Map.has_key?(changeset.changes, :password)
  end

  test "calling an invalid changeset action should throw a FunctionClauseError" do
    assert_raise FunctionClauseError, fn ->
      User.changeset(:super_fake_action, %User{}, Factory.params(:user))
    end
  end
end
