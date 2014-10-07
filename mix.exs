defmodule Letter.Mixfile do
  use Mix.Project

  def project do
    [app: :letter,
     version: "0.0.1",
     elixir: "~> 1.0.0",
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:sasl, :logger, :httpoison, :cowboy, :plug, :postgrex, :ecto],
     mod: {Letter, []},
     env: [handle_sasl_reports: false]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [
      {:timex, "~> 0.12"},
      {:jsex, "~> 2.0"},
      {:httpoison, "~> 0.4"},
      {:plug, "~> 0.8"},
      {:cowboy, "~> 1.0"},
      {:postgrex, ">= 0.0.0"},
      {:ecto, "~> 0.2"},
      {:jiffy, "0.13.1", github: "davisp/jiffy"}
    ]
  end
end
