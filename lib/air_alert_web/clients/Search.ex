defmodule AirAlertWeb.Search do
  use HTTPoison.Base

  def process_request_url(keyword) do
    "https://api.waqi.info/search/?keyword=" <> keyword <> "&token=fb8c0e42445a025635a65b449d7fc929f2d94d10"
  end

  def process_response_body(body) do
    body
    |> Poison.decode!
    |> Enum.map(fn({k, v}) -> {String.to_atom(k), v} end)
  end
end
