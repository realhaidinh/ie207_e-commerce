defmodule ECommerce.Payos do
  require Logger
  alias ECommerce.Utils.TimeUtil
  alias ECommerce.Utils.SignatureUtil

  @api_key Application.compile_env(:e_commerce, :payos_api_key)
  @client_id Application.compile_env(:e_commerce, :payos_client_id)
  @checksum_key Application.compile_env(:e_commerce, :payos_checksum_key)
  @payos_base_url "https://api-merchant.payos.vn"
  def create_payment_data(data = %{}) do
    %{
      orderCode: TimeUtil.get_current_time() |> to_string() |> String.slice(-6..-1) |> String.to_integer(),
      returnUrl: data.return_url,
      cancelUrl: data.return_url,
      amount: data.amount,
      description: data.description
    }
  end
  def create_payment_link(payment_data) do
    try do
      body =
        payment_data
        |> Map.put(
          :signature,
          SignatureUtil.create_signature_of_payment_request(payment_data, @checksum_key)
        )
        |> JSON.encode_to_iodata!()

      url = @payos_base_url <> "/v2/payment-requests"

      headers = [
        {"Accept", "application/json"},
        {"Content-type", "application/json"},
        {"Charset", "UTF-8"},
        {"x-client-id", @client_id},
        {"x-api-key", @api_key}
      ]

      fetch(:post, url, headers, body)
    rescue
      e ->
        Logger.error(Exception.format(:error, e, __STACKTRACE__))
        {:error, e}
    end
  end

  def get_payment_link_information(id) do
    url = @payos_base_url <> "/v2/payment-requests/#{id}"

    headers = [
      {"x-client-id", @client_id},
      {"x-api-key", @api_key}
    ]

    fetch(:get, url, headers)
  end

  def verify_payment_webhook_data(%{"data" => data, "signature" => signature}) do
    data_signature = SignatureUtil.create_signature_from_obj(data, @checksum_key)

    if data_signature == signature do
      {:ok, data}
    else
      {:error, "Invalid signature"}
    end
  end

  def verify_payment_webhook_data(_), do: {:error, "Missing data or signature"}

  defp fetch(method, url, headers \\ [], body \\ nil, opts \\ []) do
    request = Finch.build(method, url, headers, body, opts)

    case Finch.request(request, ECommerce.Finch) do
      {:ok, %Finch.Response{body: resp_body}} ->
        JSON.decode(resp_body)

      error ->
        error
    end
  end
end
