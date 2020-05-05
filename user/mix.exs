defmodule User.MixProject do
  use Mix.Project

  def project do
    [
      app: :user,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {User.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:poison, "~> 3.0"},
      {:plug, "~> 1.6"},
      {:cowboy, "~> 2.4"},
      {:argon2_elixir, "~> 2.0"},
      {:ecto_sql, "~> 3.0"},
      {:postgrex, ">= 0.0.0"},
      {:plug_cowboy, "~> 2.0"},
      {:faker, "~> 0.13", only: :test}
    ]
  end

  defp aliases do
    [
     test: ["ecto.create --quiet", "ecto.migrate", "test"],
    ]
  end

  # Compiled paths per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
