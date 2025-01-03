defmodule ECommerce.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ECommerceWeb.Telemetry,
      ECommerce.Repo,
      {Ecto.Migrator,
       repos: Application.fetch_env!(:e_commerce, :ecto_repos), skip: skip_migrations?()},
      {DNSCluster, query: Application.get_env(:e_commerce, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: ECommerce.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: ECommerce.Finch},
      {Task.Supervisor, name: ECommerce.TaskSupervisor},
      # Start a worker by calling: ECommerce.Worker.start_link(arg)
      # {ECommerce.Worker, arg},
      # Start to serve requests, typically the last entry
      ECommerceWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ECommerce.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ECommerceWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp skip_migrations?() do
    # By default, sqlite migrations are run when using a release
    System.get_env("RELEASE_NAME") != nil
  end
end
