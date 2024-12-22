defmodule ECommerceWeb.Admin.Dashboard.UserLive.Show do
  alias ECommerce.Orders
  alias ECommerce.Accounts
  use ECommerceWeb, :live_view

  @impl true
  def mount(_, _session, socket) do
    {:ok, assign(socket, :page_title, "Quản lý khách hàng")}
  end

  @impl true
  def handle_params(%{"id" => id}, _uri, socket) do
    {:noreply,
     socket
     |> assign(:user, Accounts.get_user!(id))
     |> stream(:orders, Orders.list_user_orders(id))}
  end
end
