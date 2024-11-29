defmodule ECommerceWeb.Admin.Dashboard.DashboardLive do
  use ECommerceWeb, :live_view

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     assign(socket, :id, id)
     |> assign(:action, :show)}
  end

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket, :id, nil)
     |> assign(:action, :index)}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    IO.inspect(params)
    Phoenix.PubSub.broadcast(ECommerce.PubSub, "dashboard", params)
    {:noreply, socket}
  end
end
