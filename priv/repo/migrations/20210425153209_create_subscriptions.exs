defmodule AirAlert.Repo.Migrations.CreateSubscriptions do
  use Ecto.Migration

  def change do
    create table(:subscriptions) do
      add :active, :boolean, default: false, null: false
      add :threshold, :string
      add :phone_number, :string

      timestamps()
    end

  end
end
