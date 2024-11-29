defmodule ECommerceWeb.Router do
  use ECommerceWeb, :router
  import ECommerceWeb.AdminAuth

  import ECommerceWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ECommerceWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_admin
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :admin do
    plug :set_layout, :admin
  end

  pipeline :public do
    plug :set_layout, :user
  end

  scope "/", ECommerceWeb do
    pipe_through [:browser, :public]

    get "/", PageController, :home
  end

  # Other scopes may use custom stacks.
  # scope "/api", ECommerceWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:e_commerce, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ECommerceWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", ECommerceWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated, :public]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{ECommerceWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", ECommerceWeb do
    pipe_through [:browser, :require_authenticated_user, :public]

    live_session :require_authenticated_user,
      on_mount: [{ECommerceWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/cart", CartLive.Index, :index
      live "/users/orders", OrderLive.Index, :index
      live "/users/orders/:id", OrderLive.Show, :show
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end
  end

  scope "/", ECommerceWeb do
    pipe_through [:browser, :public]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{ECommerceWeb.UserAuth, :mount_current_user}] do
      live "/products", ProductLive.Index, :index
      live "/products/:id", ProductLive.Show, :show
      live "/categories", CategoryLive.Index, :index
      live "/categories/:id", CategoryLive.Show, :show
      live "/checkout", CheckoutLive.Index, :index
      live "/checkout/success/:order_id", CheckoutLive.Success, :success
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end

  ## Authentication routes

  scope "/admin", ECommerceWeb do
    pipe_through [:browser, :redirect_if_admin_is_authenticated, :admin]

    live_session :redirect_if_admin_is_authenticated,
      on_mount: [{ECommerceWeb.AdminAuth, :redirect_if_admin_is_authenticated}] do
      live "/log_in", AdminLoginLive, :new
      live "/reset_password", AdminForgotPasswordLive, :new
      live "/reset_password/:token", AdminResetPasswordLive, :edit
    end

    post "/log_in", AdminSessionController, :create
  end

  scope "/admin", ECommerceWeb do
    pipe_through [:browser, :require_authenticated_admin, :admin]

    live_session :require_authenticated_admin,
      on_mount: [{ECommerceWeb.AdminAuth, :ensure_authenticated}] do
      live "/settings", AdminSettingsLive, :edit
      live "/settings/confirm_email/:token", AdminSettingsLive, :confirm_email
      live "/dashboard/catalog/products", Admin.Dashboard.DashboardLive, :products
      live "/dashboard/catalog/products/:id", Admin.Dashboard.DashboardLive, :product
      live "/dashboard/catalog/categories", Admin.Dashboard.DashboardLive, :categories
      live "/dashboard/catalog/categories/:id", Admin.Dashboard.DashboardLive, :category
      live "/dashboard/sales/orders", Admin.Dashboard.DashboardLive, :orders
      live "/dashboard/sales/orders/:id", Admin.Dashboard.DashboardLive, :order
      live "/dashboard/customers", Admin.Dashboard.DashboardLive, :users
      live "/dashboard/customers/:id", Admin.Dashboard.DashboardLive, :user
    end
  end

  scope "/admin", ECommerceWeb do
    pipe_through [:browser]

    delete "/log_out", AdminSessionController, :delete

    live_session :current_admin,
      on_mount: [{ECommerceWeb.AdminAuth, :mount_current_admin}] do
      live "/confirm/:token", AdminConfirmationLive, :edit
      live "/confirm", AdminConfirmationInstructionsLive, :new
    end
  end

  defp set_layout(conn, layout) do
    assign(conn, :current_layout, layout)
  end
end
