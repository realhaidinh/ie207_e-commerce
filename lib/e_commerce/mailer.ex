defmodule ECommerce.Mailer do
  use Swoosh.Mailer, otp_app: :e_commerce
  @email Application.compile_env!(:e_commerce, :smtp_username)
  def get_sender, do: {"UIT E-Commerce", @email}
end
