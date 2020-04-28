defmodule User.Endpoint do
  use Plug.Router

  alias Plug.{Router, Cowboy, Parsers}

  require Logger

  plug(:match)

  plug(Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Poison
  )

  plug(:dispatch)

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]}
    }
  end

  def start_link(_opts) do
    with {:ok, [port: port] = config} <- Application.fetch_env(:user, __MODULE__) do
      Logger.info("Starting server at http://localhost:#{port}/")
      Cowboy.http(__MODULE__, [], config)
    end
  end

  Router.forward("/", to: User.Router)
end
