defmodule User.Endpoint do
  use Plug.Router

  alias Plug.{Router, Cowboy, Parsers}

  require Logger

  plug(:match)
  plug(CORSPlug)

  plug(Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Poison
  )

  plug(Plug.Session,
    store: :cookie,
    key: "ipv8_session",
    encryption_salt: "qVjW6cvfM6",
    signing_salt: "X4WjwSnzrz",
    key_length: 64,
    log: :debug
  )

  plug(:put_secret_key_base)
  plug(:put_session)

  plug(:dispatch)

  def put_secret_key_base(conn, _) do
    put_in(conn.secret_key_base, Application.fetch_env!(:user, :session)[:skb])
  end

  def put_session(conn, _) do
    conn |> fetch_session
  end


  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]}
    }
  end

  def start_link(_opts) do
    with {:ok, [port: port] = config} <- Application.fetch_env(:user, __MODULE__) do
      Logger.info("Environment: #{Mix.env()}")
      Logger.info("Starting server at http://localhost:#{port}/")

      Cowboy.http(__MODULE__, [], config)
    end
  end

  Router.forward("/", to: User.Router)
end
