defmodule Tartupark.Repo.Migrations.CreatePaymentsTable do
  use Ecto.Migration

  def change do
    create table(:payments) do
      add :cost, :float
      add :payment_code, :string
      add :booking_id, references(:bookings)

      timestamps()
    end
  end
end
