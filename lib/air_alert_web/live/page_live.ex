defmodule AirAlertWeb.PageLive do
  use AirAlertWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    AirAlertWeb.Search.start()
    AirAlertWeb.Feed.start()

    {:ok, assign(socket, query: "", search_results: [], aqi: "–", forecasts: [], selected_location: "")}
  end

  @impl true
  def render(assigns) do
    ~L"""
    <section>
      <h2>Search by location</h2>

      <form phx-change ="search-locations" phx-submit ="search-locations">
        <input
          type="text"
          name="q"
          value="<%= @query %>"
          placeholder="Search for a location"
          list="results"
          autocomplete="off"
          phx-debounce="1000"/>
      </form>

      <ul id="search_results">
        <%= for %{"station" => %{"name" => name, "url" => url}} <- @search_results do %>
          <li><a href="#" phx-click="select-location" phx-value-url="<%= url %>" phx-value-name="<%= name %>"><%= name %></a></li>
        <% end %>
      </ul>
    </section>

    <%= if String.length(@selected_location) > 0 do %>
      <section>
        <h2>AQI Results for <strong><%= @selected_location %><strong></h2>

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
          </div>
        </div>
      </section>
    <% end %>
    """
  end

  @impl true
  def handle_event("search-locations", %{"q" => query}, socket) do
    {:noreply,
     assign(
       socket,
       search_results: AirAlertWeb.Search.get!(query).body[:data],
       query: query
     )}
  end

  @impl true
  def handle_event("select-location", %{"url" => url, "name" => name}, socket) do
    %{"aqi" => aqi, "forecast" => %{"daily" => %{"pm25" => pm25_forecast}}} =
      AirAlertWeb.Feed.get!(url).body[:data]

    {:noreply,
     assign(
       socket,
       aqi: aqi,
       forecasts: pm25_forecast |> Enum.take(-3),
       selected_location: name
     )}
  end
end
