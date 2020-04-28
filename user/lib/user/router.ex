defmodule User.Router do
  use Plug.Router

  plug(:match)
  plug(:dispatch)
  plug Plug.Parsers, parsers: [:urlencoded, :json], json_decoder: Poison

  alias User.{Controller}

  get "/" do
    IO.puts("test")

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(%{text: "Hello!"}))
  end

  post "/register" do
    {status, body} =
      case Controller.register(conn.body_params) do
        {:ok, _} -> {200, %{ status: "Registration Successful" }}
        {:error, changeset} -> {400, %{ errors: interpret_changeset_errors(changeset.errors) }}
      end

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, Poison.encode!(body))
  end

  match _ do
    conn
    |> send_resp(404, "404 not Found")
  end

  defp interpret_changeset_errors(list, result \\ %{})
  defp interpret_changeset_errors([], result) do
    result
  end

  defp interpret_changeset_errors(list, result) do
    [entry | tail] = list
    { name, { error, _}} = entry
    interpret_changeset_errors(tail, Map.put(result, name, error))
  end
end
