defmodule Clipboard.Mixfile do
  use Mix.Project

  @github_url "https://github.com/jayjun/clipboard"

  def project() do
    [
      app: :clipboard,
      version: "0.2.1",
      elixir: "~> 1.4",
      name: "Clipboard",
      description: "Copy and paste from system clipboard",
      deps: deps(),
      package: package(),
      source_url: @github_url,
    ]
  end

  def application() do
    [extra_applications: []]
  end

  defp deps() do
    [
      {:credo, "~> 0.8", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.16", only: :dev, runtime: false},
    ]
  end

  defp package() do
    [
      maintainers: ["Tan Jay Jun"],
      licenses: ["MIT"],
      links: %{"GitHub" => @github_url},
    ]
  end
end
