defmodule Vgwb.Mixfile do
  use Mix.Project

  def project do
    [app: :vgwb,
     version: "0.0.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :hackney]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:floki, "~> 0.17.0"},
      {:hackney, "~> 1.8.0"},
      {:html_entities, "~> 0.3.0"},
      {:monk, "~> 0.1.3"},
      {:todo, "~> 1.0.0"},
    ]
  end
end
