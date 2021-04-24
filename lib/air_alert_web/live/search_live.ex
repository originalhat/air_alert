defmodule AirAlertWeb.SearchLive do
  use AirAlertWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    AirAlertWeb.Search.start()

    {:ok, assign(socket, query: "", search_results: [], loading: false)}
  end

  @impl true
  def render(assigns) do
    ~L"""
    <section>
      <h2>Search by location</h2>

      <form phx-submit="search-locations">
        <input
          type="text"
          name="q"
          value="<%= @query %>"
          placeholder="Dublin"
          list="results"
          autocomplete="off"
          <%= if @loading, do: "readonly" %>/>

          <button <%= if @loading, do: "disabled" %>><%= if @loading, do: "Searching...", else: "Search" %></button>
      </form>

      <%= if @loading do %>
        <div class="loader">
          Loading...
        </div>
      <% end %>

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
    send(self(), {:run_location_search, query})

    socket =
      assign(socket,
        query: query,
        search_results: [],
        loading: true
      )

    {:noreply, socket}
  end

  @impl true
  def handle_info({:run_location_search, query}, socket) do
    case AirAlertWeb.Search.get!(query).body[:data] do
      [] ->
        socket =
          socket
          |> put_flash(:info, "No locations matching \"#{query}\"")
          |> assign(stores: [], loading: false)

        {:noreply, socket}

      results ->
        {:noreply, assign(socket, search_results: results, loading: false)}
    end
  end
end
