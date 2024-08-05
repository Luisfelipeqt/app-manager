defmodule App.Repo.Migrations.CreateSalesTable do
  use Ecto.Migration

  def up do
    create table(:sales) do
      add :installment, :integer, null: false, default: 1
      add :total_value, :integer, default: 0, null: false
      add :exemption, :boolean, default: false
      add :which_payment, :string, null: false
      add :which_process, :string, null: false
      add :quantity, :integer, default: 1, null: false

      add :is_paid, :boolean, null: false, default: false

      add(
        :customer_id,
        references(:customers,
          type: :binary_id,
          on_delete: :delete_all,
          on_update: :update_all
        ),
        null: false
      )

      timestamps(inserted_at: :created_at, type: :utc_datetime)
    end

    create index(:sales, [:customer_id])
  end

  def down do
    drop table(:sales)
  end
end
