defmodule User.Router do
  use Plug.Router

  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Poison
  )

  plug(:dispatch)

  alias User.{Controller}

  get "/user" do
    session = conn |> get_session
    {status, body} =
      case Controller.get_user(%{id: session["user"]}) do
        nil -> {400, %{errors: "Not Logged In"}}
        user -> {200, %{user: limit_user_return(user)}}
      end

    respond(conn, status, body)
  end

  post "/register" do
    {status, body} =
      case Controller.register(conn.body_params) do
        {:ok, user} -> {200, %{user: limit_user_return(user)}}
        {:error, changeset} -> {400, %{errors: interpret_changeset_errors(changeset.errors)}}
      end

    respond(conn, status, body)
  end

  post "/login" do
    body_params = process_body(conn.body_params)

    {conn, status, body} =
      case Controller.login(body_params) do
        {true, user} -> 
          {conn |> put_session(:user, user.id), 200, %{user: limit_user_return(user)}}
        {false, _} -> {conn, 400, %{errors: "Invalid Email or Password"}}
      end

    respond(conn, status, body)
  end

  put "/award_points" do
    body_params = process_body(conn.body_params)

    {status, body} =
      case Controller.award_points(body_params) do
        {:ok, user} -> {200, %{user: limit_user_return(user)}}
        {_, _} -> {400, %{errors: "Unknown User"}}
      end

    respond(conn, status, body)
  end

  match _ do
    conn
    |> send_resp(404, "404 not Found")
  end

  defp limit_user_return(user) do
    user
    |> Map.take([:id, :name, :email, :points])
  end

  defp respond(conn, status, body) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, Poison.encode!(body))
  end

  defp interpret_changeset_errors(list, result \\ %{})

  defp interpret_changeset_errors([], result) do
    result
  end

  defp interpret_changeset_errors(list, result) do
    [entry | tail] = list
    {name, {error, _}} = entry
    interpret_changeset_errors(tail, Map.put(result, name, error))
  end

  defp process_body(body),
    do:
      body
      |> Enum.reduce(%{}, fn {key, val}, acc -> Map.put(acc, String.to_atom(key), val) end)
end
