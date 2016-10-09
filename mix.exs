defmodule NetSuite.Mixfile do
  use Mix.Project

  def project do
    [
      app: :netsuite_elixir,
      version: "0.0.1",
      elixir: "~> 1.2",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps,
      package: [
        contributors: ["David Laprade"],
        licenses:     ["MIT"],
        links:        %{github: "https://github.com/davidlaprade/netsuite_elixir"}
      ],
      description: "Elixir NetSuite SuiteTalk webservices client"
    ]
  end

  def application do
    [
      applications: [
        :logger,
        :detergentex,
        :httpoison
      ],
      mod: {NetSuite, []}
    ]
  end

  defp deps do
    [
      {:erlsom, github: "willemdj/erlsom"},
      {:detergentex, "~> 0.0.7" },
      {:httpoison, "~> 0.9.0"},
      {:poison, "~> 2.0"}
    ]
  end
end
