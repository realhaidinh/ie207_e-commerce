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

  end
  pipeline :api do
    plug :accepts, ["json"]
  end
  pipeline :user do
    plug :fetch_current_user
  end
  pipeline :admin do
    plug :fetch_current_admin
  end
  scope "/", ECommerceWeb do
    pipe_through [:browser]

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
    pipe_through [:browser, :user, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      layout: {ECommerceWeb.Layouts, :public},
      on_mount: [{ECommerceWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", Public.UserRegistrationLive, :new
      live "/users/log_in", Public.UserLoginLive, :new
      live "/users/reset_password", Public.UserForgotPasswordLive, :new
      live "/users/reset_password/:token", Public.UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", ECommerceWeb do
    pipe_through [:browser, :user, :require_authenticated_user]

    live_session :require_authenticated_user,
      layout: {ECommerceWeb.Layouts, :public},
      on_mount: [{ECommerceWeb.UserAuth, :ensure_authenticated}] do
      live "/cart", Public.CartLive.Index, :index
      live "/users/orders", Public.OrderLive.Index, :order_index
      live "/users/orders/:id", Public.OrderLive.Show, :order_show
      live "/users/settings/confirm_email/:token", Public.UserSettingsLive, :user_confirm_email
      live "/users/settings", Public.UserSettingsLive, :profile_edit
    end
  end

  scope "/", ECommerceWeb do
    pipe_through [:browser, :user]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      layout: {ECommerceWeb.Layouts, :public},
      on_mount: [{ECommerceWeb.UserAuth, :mount_current_user}] do
      live "/products", Public.ProductLive.Index, :index
      live "/products/:id", Public.ProductLive.Show, :show
      live "/categories", Public.CategoryLive.Index, :index
      live "/categories/:id", Public.CategoryLive.Show, :show
      live "/checkout", Public.CheckoutLive.Index, :index
      live "/checkout/success/:order_id", Public.CheckoutLive.Success, :success
      live "/users/confirm/:token", Public.UserConfirmationLive, :edit
      live "/users/confirm", Public.UserConfirmationInstructionsLive, :new
    end
  end

  ## Authentication routes

  scope "/admin", ECommerceWeb do
    pipe_through [:browser, :admin, :redirect_if_admin_is_authenticated]

    live_session :redirect_if_admin_is_authenticated,
      layout: {ECommerceWeb.Layouts, :admin},
      on_mount: [{ECommerceWeb.AdminAuth, :redirect_if_admin_is_authenticated}] do
      live "/log_in", Admin.LoginLive, :new
      live "/reset_password", Admin.ForgotPasswordLive, :new
      live "/reset_password/:token", Admin.ResetPasswordLive, :edit
    end

    post "/log_in", AdminSessionController, :create
  end

  scope "/admin", ECommerceWeb do
    pipe_through [:browser, :admin, :require_authenticated_admin]

    live_session :require_authenticated_admin,
      layout: {ECommerceWeb.Layouts, :admin},
      on_mount: [{ECommerceWeb.AdminAuth, :ensure_authenticated}] do
      live "/settings", Admin.SettingsLive, :edit
      live "/settings/confirm_email/:token", Admin.SettingsLive, :confirm_email

      live "/dashboard", Admin.Dashboard.Index, :index
      live "/dashboard/sales/order", Admin.Dashboard.OrderLive.Index, :index
      live "/dashboard/sales/order/:id", Admin.Dashboard.OrderLive.Show, :show

      live "/dashboard/customer", Admin.Dashboard.UserLive.Index, :index
      live "/dashboard/customer/:id", Admin.Dashboard.UserLive.Show, :show

      live "/dashboard/catalog/category", Admin.Dashboard.CategoryLive.Index, :index
      live "/dashboard/catalog/category/edit/:id", Admin.Dashboard.CategoryLive.Index, :edit
      live "/dashboard/catalog/category/new", Admin.Dashboard.CategoryLive.Index, :new
      live "/dashboard/catalog/category/:id", Admin.Dashboard.CategoryLive.Show, :show
      live "/dashboard/catalog/category/:id/edit", Admin.Dashboard.CategoryLive.Show, :edit
      live "/dashboard/catalog/category/:id/new", Admin.Dashboard.CategoryLive.Show, :new

      live "/dashboard/catalog/product", Admin.Dashboard.ProductLive.Index, :index
      live "/dashboard/catalog/product/new", Admin.Dashboard.ProductLive.Index, :new
      live "/dashboard/catalog/product/edit/:id", Admin.Dashboard.ProductLive.Index, :edit
      live "/dashboard/catalog/product/:id", Admin.Dashboard.ProductLive.Show, :show
      live "/dashboard/catalog/product/:id/edit", Admin.Dashboard.ProductLive.Show, :edit
    end
  end

  scope "/admin", ECommerceWeb do
    pipe_through [:browser, :admin]

    delete "/log_out", AdminSessionController, :delete

    live_session :current_admin,
      on_mount: [{ECommerceWeb.AdminAuth, :mount_current_admin}] do
      live "/confirm/:token", Admin.ConfirmationLive, :edit
      live "/confirm", Admin.ConfirmationInstructionsLive, :new
    end
  end
end
