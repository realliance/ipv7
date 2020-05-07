defmodule RouterTest do
  use User.RepoCase, async: true
  use Plug.Test

  alias User.{Model.User, Factory, Router}
  alias Ecto.Query

  @opts Router.init([])

  test "POST /register should return 200 (OK) when given valid params" do
    body_params =
      Factory.params(:user)
      |> Map.take([:email, :name, :password])
      |> Poison.encode!()

    connection =
      conn(:post, "/register", body_params)
      |> put_req_header("content-type", "application/json")
      |> Router.call(@opts)

    assert connection.status == 200
  end

  test "POST /register should return 400 (Bad Request) when given invalid params" do
    body_params =
      Factory.params(:user)
      |> Map.take([:email, :password])
      |> Poison.encode!()

    connection =
      conn(:post, "/register", body_params)
      |> put_req_header("content-type", "application/json")
      |> Router.call(@opts)

    assert connection.status == 400
  end

  test "POST /register should insert a new user into the database when it returns 200 (OK)" do
    body_params =
      Factory.params(:user)
      |> Map.take([:email, :name, :password])
      |> Poison.encode!()

    before_count = Query.from(u in User, select: count())

    connection =
      conn(:post, "/register", body_params)
      |> put_req_header("content-type", "application/json")
      |> Router.call(@opts)

    after_count = Query.from(u in User, select: count())
    assert connection.status == 200
    assert after_count > before_count
  end

  test "POST /login should return 200 (OK) when given valid params" do
    raw_params = Factory.params(:user)
    Factory.insert!(:user, raw_params)

    body_params =
      raw_params
      |> Map.take([:email, :password])
      |> Poison.encode!()

    connection =
      conn(:post, "/login", body_params)
      |> put_req_header("content-type", "application/json")
      |> Router.call(@opts)

    assert connection.status == 200
  end

  test "POST /login should return 400 (Bad Request) when given invalid params" do
    raw_params = Factory.params(:user)
    wrong_params = Factory.params(:user)
    Factory.insert!(:user, raw_params)

    body_params =
      wrong_params
      |> Map.take([:email, :password])
      |> Poison.encode!()

    connection =
      conn(:post, "/login", body_params)
      |> put_req_header("content-type", "application/json")
      |> Router.call(@opts)

    assert connection.status == 400
  end

  test "PUT /award_points should return 200 (OK) when given valid params" do
    user =
      Factory.insert!(:user)
      |> Map.from_struct()

    body_params =
      user
      |> Map.take([:id])
      |> Map.put(:points, 5)
      |> Poison.encode!()

    connection =
      conn(:put, "/award_points", body_params)
      |> put_req_header("content-type", "application/json")
      |> Router.call(@opts)

    assert connection.status == 200
  end

  test "PUT /award_points should return 400 (Bad Request) when given invalid params" do
    body_params =
      %{id: Ecto.UUID.generate(), points: 5}
      |> Poison.encode!()

    connection =
      conn(:put, "/award_points", body_params)
      |> put_req_header("content-type", "application/json")
      |> Router.call(@opts)

    assert connection.status == 400
  end

  test "Requesting an invalid route will return 404 (Not Found)" do
    connection =
      conn(:get, "/award_points")
      |> put_req_header("content-type", "application/json")
      |> Router.call(@opts)

    assert connection.status == 404
  end
end
