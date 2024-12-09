defmodule ECommerceWeb.Components do
  use Phoenix.Component
  use Gettext, backend: ECommerceWeb.Gettext
  alias Phoenix.LiveView.JS
  import ECommerceWeb.CoreComponents

  attr :id, :string, required: true
  attr :table_id, :string, required: true
  attr :rows, :list, required: true
  attr :row_id, :any, default: nil, doc: "the function for generating the row id"
  attr :row_click, :any, default: nil, doc: "the function for handling phx-click on each row"
  attr :searchable, :string, default: "false"
  attr :sortable, :string, default: "false"

  attr :row_item, :any,
    default: &Function.identity/1,
    doc: "the function for mapping each row before calling the :col and :action slots"

  slot :col, required: true do
    attr :label, :string
  end

  slot :action, doc: "the slot for showing user actions in the last table column"

  def data_table(assigns) do
    assigns =
      with %{rows: %Phoenix.LiveView.LiveStream{}} <- assigns do
        assign(assigns, row_id: assigns.row_id || fn {id, _item} -> id end)
      end

    ~H"""
    <div>
      <table
        id={@table_id}
        phx-hook="DataTable"
        data-sortable={@sortable}
        data-searchable={@searchable}
        data-tbody-id={@id}
        data-tbody-phx-update={match?(%Phoenix.LiveView.LiveStream{}, @rows) && "stream"}
      >
        <thead class="text-sm text-left leading-6 text-zinc-500">
          <tr>
            <th :for={col <- @col} class="p-0 pb-4 pr-6 font-normal">
              <span class="flex items-center"><%= col[:label] %></span>
            </th>

            <th :if={@action != []} class="relative p-0 pb-4">
              <span class="sr-only"><%= gettext("Actions") %></span>
            </th>
          </tr>
        </thead>

        <tbody
          id={@id}
          phx-update={match?(%Phoenix.LiveView.LiveStream{}, @rows) && "stream"}
          class="relative divide-y divide-zinc-100 border-t border-zinc-200 text-sm leading-6 text-zinc-700"
        >
          <tr :for={row <- @rows} id={@row_id && @row_id.(row)} class="group hover:bg-zinc-50">
            <td
              :for={{col, i} <- Enum.with_index(@col)}
              phx-click={@row_click && @row_click.(row)}
              class={[
                "relative p-0",
                "font-medium text-gray-900 whitespace-nowrap dark:text-white",
                @row_click && "hover:cursor-pointer"
              ]}
            >
              <div class="block py-4 pr-6">
                <span class="absolute -inset-y-px right-0 -left-4 group-hover:bg-zinc-50 sm:rounded-l-xl" />
                <span class={["relative", i == 0 && "font-semibold text-zinc-900"]}>
                  <%= render_slot(col, @row_item.(row)) %>
                </span>
              </div>
            </td>

            <td :if={@action != []} class="relative w-14 p-0">
              <div class="relative whitespace-nowrap py-4 text-right text-sm font-medium">
                <span class="absolute -inset-y-px -right-4 left-0 group-hover:bg-zinc-50 sm:rounded-r-xl" />
                <span
                  :for={action <- @action}
                  class="relative ml-4 font-semibold leading-6 text-zinc-900 hover:text-zinc-700"
                >
                  <%= render_slot(action, @row_item.(row)) %>
                </span>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end

  attr :pages, :list, required: true
  attr :current_page, :string, default: nil

  def breadcrumb(assigns) do
    ~H"""
    <div>
      <nav class="flex" aria-label="Breadcrumb">
        <ol class="inline-flex items-center space-x-1 md:space-x-2 rtl:space-x-reverse">
          <li>
            <div class="flex items-center">
              <.link
                navigate="/"
                class="ms-1 text-sm font-medium text-gray-700 hover:text-blue-600 md:ms-2 dark:text-gray-400 dark:hover:text-white"
              >
                Trang chủ
              </.link>
            </div>
          </li>

          <li :for={page <- @pages}>
            <div class="flex items-center">
              <svg
                class="w-6 h-6 text-gray-800 dark:text-white"
                aria-hidden="true"
                xmlns="http://www.w3.org/2000/svg"
                width="24"
                height="24"
                fill="none"
                viewBox="0 0 24 24"
              >
                <path
                  stroke="currentColor"
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="m9 5 7 7-7 7"
                />
              </svg>

              <.link
                navigate={page.url}
                class="ms-1 text-sm font-medium text-gray-700 hover:text-blue-600 md:ms-2 dark:text-gray-400 dark:hover:text-white"
              >
                <%= page.title %>
              </.link>
            </div>
          </li>

          <svg
            :if={@current_page}
            class="w-6 h-6 text-gray-800 dark:text-white"
            aria-hidden="true"
            xmlns="http://www.w3.org/2000/svg"
            width="24"
            height="24"
            fill="none"
            viewBox="0 0 24 24"
          >
            <path
              stroke="currentColor"
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="m9 5 7 7-7 7"
            />
          </svg>

          <li :if={@current_page} aria-current="page">
            <div class="flex items-center">
              <span class="ms-1 text-sm font-medium text-gray-500 md:ms-2 dark:text-gray-400">
                <%= @current_page %>
              </span>
            </div>
          </li>
        </ol>
      </nav>
    </div>
    """
  end

  attr :current_user, :any, required: true
  attr :cart, :any
  attr :role, :atom, required: true
  def navbar(assigns) do
    ~H"""
    <div>
      <nav class="bg-white border-gray-200 dark:bg-gray-900">
      <%= if @role == :user do %>
        <div class="max-w-screen-xl flex flex-wrap items-center justify-between mx-auto p-4">
          <div class="flex items-center md:order-2 space-x-3 md:space-x-0 rtl:space-x-reverse">
            <%= if @current_user do %>
              <button
                type="button"
                class="block text-sm  text-black-500 truncate dark:text-gray-400"
                id="user-menu-button"
                aria-expanded="false"
                data-dropdown-toggle="user-dropdown"
                data-dropdown-placement="bottom"
              >
                <%= @current_user.email %>
              </button>
              <!-- Dropdown menu -->
              <div
                class="z-50 hidden my-4 text-base list-none bg-white divide-y divide-gray-100 rounded-lg shadow dark:bg-gray-700 dark:divide-gray-600"
                id="user-dropdown"
              >
                <ul class="py-2" aria-labelledby="user-menu-button">
                  <li>
                    <.link
                      href="/users/settings"
                      class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 dark:hover:bg-gray-600 dark:text-gray-200 dark:hover:text-white"
                    >
                      Thông tin tài khoản
                    </.link>
                  </li>

                  <li>
                    <.link
                      href="/users/orders"
                      class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 dark:hover:bg-gray-600 dark:text-gray-200 dark:hover:text-white"
                    >
                      Đơn mua
                    </.link>
                  </li>

                  <li>
                    <.link
                      href="/users/log_out"
                      method="delete"
                      class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 dark:hover:bg-gray-600 dark:text-gray-200 dark:hover:text-white"
                    >
                      Đăng xuất
                    </.link>
                  </li>
                </ul>
              </div>
            <% else %>
              <div class="flex items-center space-x-6 rtl:space-x-reverse">
                <.link
                  href="/users/log_in"
                  class="text-sm  text-blue-600 dark:text-blue-500 hover:underline"
                >
                  Đăng nhập
                </.link>

                <.link
                  href="/users/register"
                  class="text-sm  text-blue-600 dark:text-blue-500 hover:underline"
                >
                  Đăng ký
                </.link>
              </div>
            <% end %>

            <button
              data-collapse-toggle="navbar"
              type="button"
              class="inline-flex items-center p-2 w-10 h-10 justify-center text-sm text-gray-500 rounded-lg md:hidden hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-gray-200 dark:text-gray-400 dark:hover:bg-gray-700 dark:focus:ring-gray-600"
              aria-controls="navbar"
              aria-expanded="false"
            >
              <span class="sr-only">Open main menu</span>
              <svg
                class="w-5 h-5"
                aria-hidden="true"
                xmlns="http://www.w3.org/2000/svg"
                fill="none"
                viewBox="0 0 17 14"
              >
                <path
                  stroke="currentColor"
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M1 1h15M1 7h15M1 13h15"
                />
              </svg>
            </button>
          </div>

          <div id="navbar" class="justify-between hidden w-full md:flex md:w-auto md:order-1">
            <ul class="flex flex-col font-medium p-4 md:p-0 mt-4 border border-gray-100 rounded-lg bg-gray-50 md:space-x-8 rtl:space-x-reverse md:flex-row md:mt-0 md:border-0 md:bg-white dark:bg-gray-800 md:dark:bg-gray-900 dark:border-gray-700">
              <li>
                <.link
                  navigate="/"
                  class="block py-2 px-3 text-black bg-white-700 rounded md:bg-transparent md:text-black-700 md:p-0 md:dark:text-blue-500"
                  aria-current="page"
                >
                  Trang chủ
                </.link>
              </li>
            </ul>
          </div>
        </div>

        <div class="max-w-screen-xl grid grid-cols-6 flex justify-between flex-wrap items-center mx-auto p-4">
          <div class="flex basis-1/3 col-start-2 col-end-6 md:order-2 mr-2.5">
            <button
              type="button"
              data-collapse-toggle="navbar"
              aria-controls="navbar"
              aria-expanded="false"
              class="md:hidden text-gray-500 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-700 focus:outline-none focus:ring-4 focus:ring-gray-200 dark:focus:ring-gray-700 rounded-lg text-sm p-2.5 me-1"
            >
              <svg
                class="w-5 h-5"
                aria-hidden="true"
                xmlns="http://www.w3.org/2000/svg"
                fill="none"
                viewBox="0 0 20 20"
              >
                <path
                  stroke="currentColor"
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="m19 19-4-4m0-7A7 7 0 1 1 1 8a7 7 0 0 1 14 0Z"
                />
              </svg>
               <span class="sr-only">Search</span>
            </button>

            <div class="relative hidden md:block w-full">
              <div class="absolute inset-y-0 start-0 flex items-center ps-3 pointer-events-none">
                <svg
                  class="w-4 h-4 text-gray-500 dark:text-gray-400"
                  aria-hidden="true"
                  xmlns="http://www.w3.org/2000/svg"
                  fill="none"
                  viewBox="0 0 20 20"
                >
                  <path
                    stroke="currentColor"
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="m19 19-4-4m0-7A7 7 0 1 1 1 8a7 7 0 0 1 14 0Z"
                  />
                </svg>
                 <span class="sr-only">Search icon</span>
              </div>

              <input
                type="text"
                id="search-navbar"
                class="block w-full p-2 ps-10 text-sm text-gray-900 border border-gray-300 rounded-lg bg-gray-50 focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"
                placeholder="Search..."
              />
            </div>
          </div>

          <div class="order-3 flex col-start-6 justify-center">
            <.button
              id="dropdownDelayButton"
              phx-click={JS.navigate("/cart")}
              data-dropdown-toggle="dropdownDelay"
              data-dropdown-delay="300"
              data-dropdown-trigger="hover"
              class="text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm px-5 py-2.5 text-center inline-flex items-center dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800"
              type="button"
            >
              Giỏ hàng
            </.button>
            <!-- Dropdown menu -->
            <div
              id="dropdownDelay"
              class="grid grid-cols-1 justify-items-stretch w-1/5 z-10 hidden bg-white divide-y divide-gray-100 shadow dark:bg-gray-700"
            >
              <p>Sản phẩm mới thêm</p>

              <ul
                class="py-2 text-sm text-gray-700 dark:text-gray-200"
                aria-labelledby="dropdownDelayButton"
              >
                <%= for item <- @cart.cart_items do %>
                  <li>
                    <div class="flex justify-between m-1.5">
                      <p><%= item.product.title %></p>

                      <p><%= item.price_when_carted %></p>
                    </div>
                  </li>
                <% end %>
              </ul>

              <.button class="justify-self-end w-2/3 m-1.5" phx-click={JS.patch("/cart")}>
                Xem giỏ hàng
              </.button>
            </div>
          </div>
        </div>
        <% else %>
        <div class="max-w-screen-xl flex flex-wrap flex-row-reverse items-center justify-between mx-auto p-4">
          <div class="flex items-center md:order-2 space-x-3 md:space-x-0">
          <%= if @current_user do %>


            <.link
                navigate="/admin/settings"
                class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 dark:hover:bg-gray-600 dark:text-gray-200 dark:hover:text-white"
            >
              Thông tin tài khoản <%= @current_user.email %>
            </.link>
            <.link
                href="/admin/log_out"
                method="delete"
                class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 dark:hover:bg-gray-600 dark:text-gray-200 dark:hover:text-white"
            >
              Đăng xuất
            </.link>
          <% else %>
          <div class="flex items-center space-x-6 rtl:space-x-reverse">
                <.link
                  href="/admin/log_in"
                  class="text-sm  text-blue-600 dark:text-blue-500 hover:underline"
                >
                  Đăng nhập
                </.link>
              </div>
          <% end %>
          </div>
        </div>
        <% end %>
      </nav>
    </div>
    """
  end

  attr :product, :any, required: true

  def product_card(assigns) do
    ~H"""
    <div
      phx-click={JS.navigate("/products/#{@product.id}")}
      class="hover:cursor-pointer w-full max-w-sm bg-white border border-gray-200 rounded-lg shadow dark:bg-gray-800 dark:border-gray-700"
    >
      <img
        class="p-8 rounded-t-lg"
        src="https://flowbite.com/docs/images/products/apple-watch.png"
        alt="product image"
      />
      <div class="px-5 pb-5">
        <h5 class="text-xl font-semibold tracking-tight text-gray-900 dark:text-white">
          <%= @product.title %>
        </h5>

        <div class="flex items-center mt-2.5 mb-5">
          <div class="flex items-center space-x-1 rtl:space-x-reverse">
            <svg
              class="w-4 h-4 text-yellow-300"
              aria-hidden="true"
              xmlns="http://www.w3.org/2000/svg"
              fill="currentColor"
              viewBox="0 0 22 20"
            >
              <path d="M20.924 7.625a1.523 1.523 0 0 0-1.238-1.044l-5.051-.734-2.259-4.577a1.534 1.534 0 0 0-2.752 0L7.365 5.847l-5.051.734A1.535 1.535 0 0 0 1.463 9.2l3.656 3.563-.863 5.031a1.532 1.532 0 0 0 2.226 1.616L11 17.033l4.518 2.375a1.534 1.534 0 0 0 2.226-1.617l-.863-5.03L20.537 9.2a1.523 1.523 0 0 0 .387-1.575Z" />
            </svg>
          </div>

          <span class="bg-blue-100 text-blue-800 text-xs font-semibold px-2.5 py-0.5 rounded dark:bg-blue-200 dark:text-blue-800 ms-3">
            <%= @product.rating %>
          </span>
        </div>

        <div class="flex items-center justify-between">
          <span class="text-3xl font-bold text-gray-900 dark:text-white"><%= @product.price %></span>
        </div>
      </div>
    </div>
    """
  end
end
