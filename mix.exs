defmodule MySensors.Mixfile do
  use Mix.Project

  def project do
    [
      app: :my_sensors,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: ["test": :test, "coveralls": :test, "coveralls.detail": :test, "coveralls.post": :test, "coveralls.html": :test]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {MySensors.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:nerves_uart, "~> 0.1.2"},
      {:ecto, "~> 2.2.2"},
      {:sqlite_ecto2, "~> 2.2.1"},
      {:ex_doc, "~> 0.18.1", only: [:dev, :test]},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
      {:cowboy, "~> 1.0.0"},
      {:plug, "~> 1.0"},
      {:poison, "~> 3.1.0"},
      {:faker, "~> 0.9", only: [:dev, :test]},
      {:excoveralls, "~> 0.7", only: :test}
    ]
  end
end
