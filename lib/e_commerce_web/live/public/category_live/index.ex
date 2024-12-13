defmodule ECommerceWeb.Public.CategoryLive.Index do
  use ECommerceWeb, :live_view

  alias ECommerce.Catalog

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Tất cả danh mục")
     |> stream_configure(:categories, dom_id: fn {cat, _} -> "category-#{cat.id}" end)}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    categories =
      Catalog.list_categories()
      |> Enum.reduce(%{}, fn
        %{path: "/"} = category, acc ->
          Map.put(acc, category, [])

        %{path: path} = category, acc ->
          parent =
            acc
            |> Enum.find(fn {key, _} -> String.starts_with?(path, "/#{key.id}") end)
            |> elem(0)

          Map.update!(acc, parent, &[category | &1])
      end)

    {:noreply, stream(socket, :categories, categories, reset: true)}
  end
end
