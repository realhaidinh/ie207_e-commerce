defmodule ECommerceWeb.Admin.Dashboard.DashboardLive do
  use ECommerceWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :is_modal_open, false)}
  end

  @impl true
  def handle_params(%{"id" => id} = _params, _uri, socket) do
    {:noreply, assign(socket, :item_id, id)}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, assign(socket, :item_id, nil)}
  end

  @impl true
  def handle_info(:open_modal, socket) do
    {:noreply, assign(socket, :is_modal_open, true)}
  end

  def handle_info(:close_modal, socket) do
    {:noreply, assign(socket, :is_modal_open, false)}
  end

  defp get_page_component(:category), do: ECommerceWeb.Admin.Dashboard.CategoryShow
  defp get_page_component(:categories), do: ECommerceWeb.Admin.Dashboard.CategoryIndex
  defp get_page_component(:product), do: ECommerceWeb.Admin.Dashboard.ProductShow
  defp get_page_component(:products), do: ECommerceWeb.Admin.Dashboard.ProductIndex
  defp get_page_component(:order), do: ECommerceWeb.Admin.Dashboard.OrderShow
  defp get_page_component(:orders), do: ECommerceWeb.Admin.Dashboard.OrderIndex
  defp get_page_component(:user), do: ECommerceWeb.Admin.Dashboard.UserShow
  defp get_page_component(:users), do: ECommerceWeb.Admin.Dashboard.UserIndex
  defp get_page_id(:category), do: "Category"
  defp get_page_id(:categories), do: "Categories"
  defp get_page_id(:product), do: "Product"
  defp get_page_id(:products), do: "Products"
  defp get_page_id(:order), do: "Order"
  defp get_page_id(:orders), do: "Orders"
  defp get_page_id(:user), do: "Customer"
  defp get_page_id(:users), do: "Customers"
end
