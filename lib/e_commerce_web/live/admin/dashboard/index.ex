defmodule ECommerceWeb.Admin.Dashboard.Index do
  use ECommerceWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :page_title, "Quản lý cửa hàng")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
    </div>
    """
  end
end
