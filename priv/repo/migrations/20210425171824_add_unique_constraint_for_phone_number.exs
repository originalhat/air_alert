defmodule AirAlert.Repo.Migrations.AddUniqueConstraintForPhoneNumber do
  use Ecto.Migration

  def change do
    create unique_index(:subscriptions, [:phone_number])
  end
end
