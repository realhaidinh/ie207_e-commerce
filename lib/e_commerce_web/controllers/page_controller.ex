defmodule ECommerceWeb.PageController do
  use ECommerceWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  def env(conn, _params) do
    IO.inspect(conn.remote_ip)
    send_resp(conn, 404, "Not found")
  end
end
