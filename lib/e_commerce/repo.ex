defmodule ECommerce.Repo do
  use Ecto.Repo,
    otp_app: :e_commerce,
    adapter: Ecto.Adapters.SQLite3
end
