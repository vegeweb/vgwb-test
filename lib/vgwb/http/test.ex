defmodule Vgwb.Http.Test do

  @ctx_defaults %{
    results: [],
    label: "No label",
    title_prefix: ""
  }

  def create_context(opts = %{}) do
    @ctx_defaults
    |> Map.merge(opts)
  end

  def create_context(kv_opts) do
    Map.new(kv_opts)
    |> create_context()
  end

  def label(ctx, lab),
    do: Map.put(ctx, :label, lab)

  @http_request_defaults %{
    http_method: :get,
    http_headers: [],
    http_payload: "",
    http_options: []
  }

  def http_GET(ctx = %{endpoint: endpoint}, opts) do
    %{path: url} = opts
    ctx
    |> Map.put(:req, (
        Map.merge(@http_request_defaults, opts)
        |> Map.put(:url, endpoint <> opts.path)
        |> Map.put(:http_method, "GET")
       ))
    |> http_request()
  end

  defp http_request(ctx = %{req: req}) do
    :hackney.request(
      req.http_method,
      req.url,
      req.http_headers,
      req.http_payload,
      req.http_options
    )
    |> case do
        {:ok, status_code, resp_headers, client_ref} ->
          {:ok, body} = :hackney.body(client_ref)
          http_data = %{
            status_code: status_code,
            resp_headers: resp_headers,
            body: body,
            client_ref: client_ref
          }
          ctx = Map.put(ctx, :resp, http_data)
          {:ok, ctx}
        other ->
          other
    end
  end

  def assert_title(ctx, expected) do
    %{title_prefix: prefix} = ctx
    title =
      if String.starts_with?(expected, prefix) do
        expected
      else
        prefix <> expected
      end
    assert_unique_tag(ctx, "title", title)
  end

  def assert_unique_tag(ctx, tag, expected) do
    %{resp: resp} = ctx
    result =
      Floki.find(resp.body, tag)
      |> case do
          [{^tag, _, [^expected]}] ->
            {:success, {:unique_tag, tag, expected}}
          [{^tag, _, [other|_]}] ->
            {:fail, {:unique_tag, tag, expected, other}}
          other ->
            {:error, {:unique_tag, tag, other}}
         end
    put_result(ctx, result)
  end

  defp put_result(ctx, result) do
    ctx
    |> Map.update(:results, [], fn(rs) -> [result|rs] end)
  end

  def print_results(ctx) do
    print_label(ctx)
    print_req(ctx)
    ctx.results
      |> Enum.each(&print_result/1)
  end

  defp print_label(ctx = %{label: label}) do
    IO.puts "## #{label}"
  end

  defp print_req(ctx = %{req: req}) do
    IO.puts "#{req.http_method} #{req.path}"
  end

  defp print_result({:success, {:unique_tag, tag, expected}}) do
    [
      IO.ANSI.format([:green, " ✔"]),
      " The <#{tag}/> value is correct\n",
      "    expected: #{expected}\n",
    ]
    |> IO.puts
  end

  defp print_result({:fail, {:unique_tag, tag, expected, actual}}) do
    [
      [:red, " ✘"],
      " The <#{tag}/> value is incorrect\n",
      "    expected: #{expected}\n",
      "    actual:   #{actual}",
    ]
    |> IO.ANSI.format
    |> IO.puts
  end

  defp print_result({:error, {:unique_tag, tag, []}}) do
    [
      [:red, " ✘"],
      " The <#{tag}/> value is incorrect",
    ]
    |> IO.ANSI.format
    |> IO.puts
  end

  defp print_result(result) do
    [
      [:red, " ✘"],
      " Unknown result format : ",
      (inspect result),
    ]
    |> IO.ANSI.format
    |> IO.puts
  end

end
