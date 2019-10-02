defmodule Watchexs.MixProject do
  use Mix.Project

  def project do
    [
      app: :watchexs,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Watchexs, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo,          "~> 0.9",   only: [:dev, :test]},
      {:dialyxir,       "~> 1.0.0-rc.7", only: [:dev], runtime: false},
      {:file_system,    "~> 0.2"},
      {:mix_test_watch, "~> 0.8", only: :dev, runtime: false}
    ]
  end
end
