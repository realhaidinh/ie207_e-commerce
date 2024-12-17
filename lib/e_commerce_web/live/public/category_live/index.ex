defmodule ECommerceWeb.Public.CategoryLive.Index do
  use ECommerceWeb, :live_view

  alias ECommerce.Catalog

  @impl true
  def mount(_params, _session, socket) do
    categories =
      Catalog.list_categories()
      |> Enum.reduce([], fn
        %{path: "/"} = category, acc ->
          [Map.put(category, :subcategories, []) | acc]

        %{path: path} = category, acc ->
          pid = Enum.find_index(acc, &String.starts_with?(path, "/#{&1.id}"))

          List.update_at(
            acc,
            pid,
            &Map.update!(&1, :subcategories, fn sub -> [category | sub] end)
          )
      end)
      |> Enum.sort_by(& &1.title)

    {:ok,
     socket
     |> assign(:page_title, "Tất cả danh mục")
     |> stream(:categories, categories, reset: true)}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end
end
