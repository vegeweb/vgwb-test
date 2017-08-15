defmodule Mix.Tasks.TestForumEndpoint do
  use Mix.Task
  use Monk
  alias Mix.Shell.IO, as: Sh
  alias Keyword, as: K
  alias Vgwb.Http.Test, as: HT
  @shortdoc "Tests several requests against a vegeweb forum endpoint"

  @default_endpoint "https://vegeweb.org"
  @base_title HtmlEntities.decode("Végéweb - Forum Végétarien, Végétalien et Vegan &bull; ")


  def run(args) do
    {options, _} = OptionParser.parse!(
      args,
      switches: [endpoint: [:string]],
      aliases: [
        e: :endpoint
      ]
    )
    endpoint = K.get(options, :endpoint, @default_endpoint)
    Sh.info("Testing endpoint #{endpoint}")

    :hackney.start()
    ctx = HT.create_context(endpoint: endpoint, title_prefix: @base_title)

    for check <- checks,
      do: (monk check.(ctx) |> HT.print_results())
  end

  defp checks() do
    [
      &check_home_page/1,
      &check_forum_page/1,
      &check_topic_page/1,
    ]
  end

  defp check_home_page(ctx) do
    monk ctx
    |> HT.label("Home page")
    |> HT.http_GET(%{path: "/"})
    |> IO.inspect
    |> HT.assert_title("Page d’index")
  end

  defp check_forum_page(ctx) do
    monk ctx
    |> HT.http_GET(%{path: "/cuisine.html"})
    |> HT.assert_title("Voir le forum - Cuisine")
  end

  defp check_topic_page(ctx) do
    monk ctx
    |> HT.http_GET(%{path: "/mini-hamburgers-vegetariens-t20616.html"})
    |> HT.assert_title("Afficher le sujet - Mini-hamburgers végétariens")
  end

end
