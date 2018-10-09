defmodule MySensors.Mixfile do
  use Mix.Project

  def project do
    [
      app: :my_sensors,
      version: "0.2.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      description: description(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        test: :test,
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
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
      {:nerves_uart, "~> 1.2"},
      {:ecto, "2.2.5"},
      {:sqlite_ecto2, "~> 2.2", optional: true},
      
      {:ex_doc, "~> 0.19", only: [:docs]},
      {:dialyxir, "~> 1.0.0-rc.3", only: [:dev], runtime: false},
      {:faker, "~> 0.10"},
      {:excoveralls, "~> 0.10", only: :test}
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      maintainers: ["konnorrigby@gmail.com"],
      links: %{
        "GitHub" => "https://github.com/connorrigby/my_sensors",
        "MySensors" => "https://www.mysensors.org/"
      },
      source_url: "https://github.com/connorrigby/my_sensors"
    ]
  end

  defp description do
    """
    MySensors is an open source hardware and software community focusing on do-it-yourself home automation and Internet of Things.
    """
  end
end
