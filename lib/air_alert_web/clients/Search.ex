defmodule AirAlertWeb.Search do
  use HTTPoison.Base

  def process_request_url(keyword) do
    "https://api.waqi.info/search/?keyword=" <> keyword <> "&token=#{Application.get_env(:air_alert, AirAlert.AQI)[:token]}"
  end

  def process_response_body(body) do
    body
    |> Poison.decode!
    |> Enum.map(fn({k, v}) -> {String.to_atom(k), v} end)
  end
end
