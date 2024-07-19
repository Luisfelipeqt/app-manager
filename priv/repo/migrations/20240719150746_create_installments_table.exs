defmodule App.Repo.Migrations.CreateInstallmentsTable do
  use Ecto.Migration

  def up do
    create table(:installments, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :expiration_date, :date, null: false
      add :installment_number, :integer, null: false, default: 1
      add :value, :integer, default: 0, null: false

      add :is_paid, :boolean, null: false, default: false

      add(
        :sale_id,
        references(:sales, type: :binary_id, on_delete: :delete_all, on_update: :update_all),
        null: false
      )

      add :deleted_at, :string, null: true, default: nil
      timestamps(inserted_at: :created_at, type: :utc_datetime)
    end

    create index(:installments, :sale_id)
  end

  def down do
    drop table(:installments)
  end
end
