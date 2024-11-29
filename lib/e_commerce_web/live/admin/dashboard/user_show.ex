defmodule ECommerceWeb.Admin.Dashboard.UserShow do
  alias ECommerce.Accounts
  use ECommerceWeb, :live_component
  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(:user, Accounts.get_user!(assigns.item_id))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
    </div>
    """
  end
end
