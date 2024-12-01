defmodule ECommerceWeb.Admin.User.Index do
  alias ECommerce.Accounts
  use ECommerceWeb, :live_component
  @impl true
  def mount(socket) do
    {:ok, assign(socket, :users, Accounts.list_user())}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div></div>
    """
  end
end
