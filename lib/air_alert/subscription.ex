defmodule AirAlert.Subscription do
  use Ecto.Schema

  import Ecto.Changeset

  alias AirAlert.Repo

  schema "subscriptions" do
    field :active, :boolean, default: true
    field :threshold, Ecto.Enum, values: [:good, :moderate, :sensitive, :unhealthy, :very_unhealthy, :hazardous]
    field :phone_number, :string

    timestamps()
  end

  @doc false
  def changeset(subscription, attrs) do
    subscription
    |> cast(attrs, [:active, :threshold, :phone_number])
    |> validate_required([:threshold, :phone_number])
    |> validate_format(:phone_number, ~r/^(\+\d{1,2}\s)?\(?\d{3}\)?[\s.-]\d{3}[\s.-]\d{4}$/, message: "Invalid phone number format")
  end

  def create_subscription(attrs \\ %{}) do
    %__MODULE__{}
    |> changeset(attrs)
    |> update_change(:phone_number, &Regex.replace(~r/(?!\d)./, &1, ""))
    |> Repo.insert()
  end
end
