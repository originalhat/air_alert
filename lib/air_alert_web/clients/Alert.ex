defmodule AirAlertWeb.Alert do
  use HTTPoison.Base

  @twilio_account_sid Application.get_env(:air_alert, AirAlert.Twilio)[:account_sid]
  @twilio_auth_token Application.get_env(:air_alert, AirAlert.Twilio)[:auth_token]

  def process_request_url(_params) do
    "https://api.twilio.com/2010-04-01/Accounts/#{@twilio_account_sid}/Messages.json"
  end

  def process_request_body(%{"message" => message, "from_ph" => from_ph, "to_ph" => to_ph}) do
    {:form, [From: from_ph, To: to_ph, Body: message]}
  end

  def process_request_headers(headers) do
    credentials = "#{@twilio_account_sid}:#{@twilio_auth_token}" |> Base.encode64()

    [{"Authorization", "Basic #{credentials}"} | headers ]
  end

  def process_response_body(body) do
    body
    |> Poison.decode!
    |> Enum.map(fn({k, v}) -> {String.to_atom(k), v} end)
  end
end
