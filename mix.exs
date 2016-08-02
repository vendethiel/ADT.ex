defmodule Adt.Mixfile do
  use Mix.Project

  def project do
    [app: :adt,
     version: "1.0.0",
     elixir: "~> 1.2",
     description: description,
     package: package,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    []
  end

  defp description do
    """
    A light ADT module for Elixir.
    """
  end

  defp package do
    [
      name: :adt,
      files: ["lib", "mix.exs"]
    ]
  end
end
