defmodule Eon.Mixfile do
  use Mix.Project

  @version File.read!("VERSION") |> String.strip

  def project do
    [
      app: :eon,
      version: @version,
      elixir: "~> 1.0",
      description: "Use Elixir maps as a document storage format.",
      deps: deps(),
      package: package()
   ]
  end

  def application do
    [
      applications: []
    ]
  end

  defp deps do
    [
      {:earmark, ">= 0.0.0", only: :dev},
      {:ex_doc, "~> 0.10", only: :dev}
    ]
  end

  defp package do
    [
      files: ~w(lib mix.exs README.md LICENSE VERSION),
      maintainers: ["Michael Matyi"],
      licenses: ["Apache"],
      links: %{"GitHub" => "https://github.com/supernintendo/eon"}
    ]
  end
end
