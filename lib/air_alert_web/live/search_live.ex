defmodule AirAlertWeb.SearchLive do
  use AirAlertWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    AirAlertWeb.Search.start()

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
          <li>
            <%= live_patch name, to: Routes.feed_path(@socket, :index, %{name: name, url: url}) %>
          </li>
        <% end %>
      </ul>
    </section>
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
end
