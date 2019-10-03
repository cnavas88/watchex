defmodule Watchexs.MixProject do
  use Mix.Project

  def project do
    [
      app: :watchexs,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      # dialyzer: [
      #   plt_file: {:no_warn, "priv/plts/dialyzer.plt"},
      #   ignore_warnings: ".dialyzer_ignore.exs"
      # ],
      aliases: aliases(),
      elixirc_options: [warnings_as_errors: true]
    ]
  end

  defp aliases do
    [
      quality: ["format", "credo --strict", "dialyzer"],
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
      {:file_system, "~> 0.2"},
      {:mix_test_watch, "~> 0.8", only: :dev, runtime: false}
    ]
  end
end
