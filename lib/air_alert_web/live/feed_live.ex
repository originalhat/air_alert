defmodule AirAlertWeb.FeedLive do
  use AirAlertWeb, :live_view

  @impl true
  def mount(%{"name" => name, "url" => url}, _session, socket) do
    AirAlertWeb.Feed.start()

    %{"aqi" => aqi, "forecast" => %{"daily" => %{"pm25" => pm25_forecast}}} =
      AirAlertWeb.Feed.get!(url).body[:data]

    {:ok, assign(socket, name: name, aqi: aqi, forecasts: pm25_forecast |> Enum.take(-3))}

    # {:ok, assign(socket, name: "", aqi: "", forecasts: [])}
  end

  @impl true
  def render(assigns) do
    ~L"""
    <section>
      <h2>AQI Results for <strong><%= @name %></strong></h2>

      <div class="results">
        <span class="aqi">
          <div>TODAY</div>
          <div class="aqi__value">
            <%= @aqi %>
          </div>
        </span>

        <span class="forecasts">
          <%= for forecast <- @forecasts do %>
            <span class="forecast">
              <div><%= forecast["day"]%></div>
              <div class="aqi__value"><%= forecast["avg"]%></div>
            </span>
          <% end %>
        </span>
      </div>
    </section>

    <section class="alerts">
      <h2>Configure alerts</h2>

      <p>Receive SMS alerts when the AQI exceeds safe levels for <strong><%= @name %></strong>.</p>

      <form phx-submit ="configure-alert">
        <label>AQI threshold<label>
        <select name="aqi">
          <option value="good">Good (0-50)</option>
          <option value="moderate">Moderate (51-100)</option>
          <option value="sensitive">Unhealthy for sensitive groups (101-150)</option>
          <option value="unhealthy">Unhealthy (151-200)</option>
          <option value="very_unhealthy">Very unhealthy (201-300)</option>
          <option value="hazardous">Hazardous (301+)</option>
        </select>

        <label>Phone number</label>
        <input type="tel" pattern="[0-9]{3}-[0-9]{3}-[0-9]{4}">

        <button>Submit</button>
      </form>
    </section>
    """
  end
end
