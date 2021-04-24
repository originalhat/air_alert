defmodule AirAlertWeb.Feed do
  use HTTPoison.Base

  def process_request_url(location) do
    "https://api.waqi.info/feed/" <> location <> "/?token=fb8c0e42445a025635a65b449d7fc929f2d94d10"
  end

  def process_response_body(body) do
    body
    |> Poison.decode!
    |> Enum.map(fn({k, v}) -> {String.to_atom(k), v} end)
  end
end
