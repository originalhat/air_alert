defmodule AirAlertWeb.FeedLive do
  use AirAlertWeb, :live_view

  alias AirAlert.Subscription

  @impl true
  def mount(%{"name" => name, "url" => url}, _session, socket) do
    AirAlertWeb.Feed.start()

    %{"aqi" => aqi, "forecast" => %{"daily" => %{"pm25" => pm25_forecast}}} =
      AirAlertWeb.Feed.get!(url).body[:data]

    {:ok,
     assign(socket,
       name: name,
       aqi: aqi,
       forecasts: pm25_forecast |> Enum.take(-3),
       changeset: Subscription.changeset(%Subscription{}, %{}),
       submit: false
     )}
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

      <%= if @submit do %>
        <p><em>Thanks for signing up for notifications!<em></p>
      <% else %>
        <%= f = form_for @changeset, "#", [phx_change: :validate, phx_submit: :save] %>
          <%= label f, :phone_number %>
          <%= telephone_input f, :phone_number, placeholder: "Phone", autocomplete: "off", phx_debounce: "blur" %>
          <%= error_tag f, :phone_number %>

          <%= label f, :threshold %>
          <%= select f, :threshold, aqi_keys() %>
          <%= error_tag f, :threshold %>

          <%= submit "Save" %>
        </form>
      <% end %>
    </section>
    """
  end

  def aqi_keys() do
    [
      "Good (0-50)": "good",
      "Moderate (51-100)": "moderate",
      "Unhealthy for sensitive groups (101-150)": "sensitive",
      "Unhealthy (151-200)": "unhealthy",
      "Very unhealthy (201-300)": "very_unhealthy",
      "Hazardous (301+)": "hazardous"
    ]
  end

  @impl true
  def handle_event("validate", %{"subscription" => subscription_params}, socket) do
    changeset =
      %Subscription{}
      |> Subscription.changeset(subscription_params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  @impl true
  def handle_event("save", %{"subscription" => subscription_params}, socket) do
    case Subscription.create_subscription(subscription_params) do
      {:ok, _subscription} ->
        {:noreply, assign(socket, submit: true)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
