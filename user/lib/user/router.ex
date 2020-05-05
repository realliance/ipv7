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

  post "/register" do
    {status, body} =
      case Controller.register(conn.body_params) do
        {:ok, _} -> {200, %{status: "Registration Successful"}}
        {:error, changeset} -> {400, %{errors: interpret_changeset_errors(changeset.errors)}}
      end

    respond(conn, status, body)
  end

  post "/login" do
    body_params = process_body(conn.body_params)

    {status, body} =
      case Controller.login(body_params) do
        {true, user} -> {200, %{user: %{email: user.email, name: user.name, points: user.points}}}
        {false, _} -> {400, %{errors: "Invalid Email or Password"}}
      end

    respond(conn, status, body)
  end

  put "/award_points" do
    body_params = process_body(conn.body_params)

    {status, body} =
      case Controller.award_points(body_params) do
        {:ok, user} -> {200, %{user: %{email: user.email, name: user.name, points: user.points}}}
        {_, _} -> {400, %{errors: "Unknown User"}}
      end

    respond(conn, status, body)
  end

  match _ do
    conn
    |> send_resp(404, "404 not Found")
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
