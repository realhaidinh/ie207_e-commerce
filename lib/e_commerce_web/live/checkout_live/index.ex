defmodule ECommerceWeb.CheckoutLive.Index do
  use ECommerceWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
  @impl true
  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

end
