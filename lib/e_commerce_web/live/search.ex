defmodule ECommerceWeb.SearchFormComponent do
  alias ECommerce.Catalog
  use ECommerceWeb, :live_component
  @impl true
  def render(assigns) do
    ~H"""
    <div class="col-start-2 col-end-6 md:order-2 mr-2.5 relative">
      <form
        class="w-full flex"
        phx-change="update"
        phx-target={@myself}
        phx-throttle="500"
        phx-submit={JS.navigate("/products?keyword=#{@keyword}")}
      >
        <input
          class="w-3/4 rounded"
          name="keyword"
          type="text"
          placeholder="Tìm kiếm sản phẩm"
          autocomplete="off"
          phx-focus={JS.show(to: "#search-popover", transition: "fade-out")}
          phx-blur={JS.hide(to: "#search-popover", transition: "fade-out")}
        />
        <button class="ml-8" type="submit">
          Tìm kiếm
        </button>
      </form>

      <div
        id="search-popover"
        role="tooltip"
        title="search-popover"
        class="hidden absolute top-[calc(100%-1px)] left-0 bg-white w-[calc(75%-0.5rem)] rounded ml-1"
      >
        <div id="product_preview" class="px-3 py-2 flex flex-col">
          <.link
            :for={{dom_id, product} <- @streams.products}
            id={dom_id}
            navigate={~p"/products/#{product}"}
            class="pl-1"
          >
            <%= product.title %>
          </.link>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:keyword, "")
     |> stream(:products, [])}
  end

  @impl true
  def handle_event("update", %{"keyword" => keyword} = opts, socket) do
    products =
      if keyword == "", do: [], else: Catalog.search_product(opts)

    {:noreply,
     socket
     |> assign(:keyword, keyword)
     |> stream(:products, products, reset: true)}
  end
end
