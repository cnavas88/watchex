defmodule Watchexs.MixProject do
  use Mix.Project

  def project do
    [
      app: :watchexs,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      elixirc_options: [warnings_as_errors: true],
      description: description(),
      package: package(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],

      # Docs
      source_url: "https://github.com/cnavas88/watchexs",
      homepage_url: "https://github.com/cnavas88/watchexs"
    ]
  end

  defp description do
    "Watchexs is a real time recompiler and reload the changes."
  end

  defp package do
    [
      maintainers: ["Carlos Navas"],
      licenses: [],
      links: %{
        "Github" => "https://github.com/cnavas88/watchexs"
      }
    ]
  end

  defp aliases do
    [
      quality: ["format", "credo --strict", "dialyzer", "inch"],
      "quality.ci": [
        "format --check-formatted",
        "credo --strict",
        "dialyzer --halt-exit-status"
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :ex_unit, :iex, :mix],
      mod: {Watchexs, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 0.9", only: [:dev, :test]},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
      {:excoveralls, "~> 0.10", only: :test},
      {:inch_ex, github: "rrrene/inch_ex", only: [:dev, :test]},
      {:file_system, "~> 0.2"},
      {:mix_test_watch, "~> 0.8", only: :dev, runtime: false}
    ]
  end
end
