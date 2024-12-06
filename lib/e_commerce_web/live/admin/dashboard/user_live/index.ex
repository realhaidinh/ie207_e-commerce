defmodule ECommerceWeb.Admin.Dashboard.UserLive.Index do
alias ECommerce.Accounts
  use ECommerceWeb, :live_view

  @impl true
  def mount(_, _session, socket) do
    {:ok,
    socket
    |> assign(:page_title, "Quản lý khách hàng")
    |> assign(:users, Accounts.list_user())}
  end

end
