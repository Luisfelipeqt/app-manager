defmodule App.Repo.Migrations.CreateCustomersTable do
  use Ecto.Migration

  def up do
    create table(:customers) do
      add :gender, :string
      add :birthday, :date
      add :cpf, :string, size: 14, null: false
      add :email, :string, null: false
      add :full_name, :string, null: false
      add :mobile_phone, :string, size: 20, null: false
      add :registration, :date
      add :image_url, :string, null: false, default: "/images/default-user.svg"

      # Endereço
      add :address, :string, null: false, default: "Não informado"
      add :locality, :string, null: false, default: "Não informado"
      add :neighborhood, :string, null: false, default: "Não informado"
      add :state, :char, size: 2, null: false, default: "SP"

      add :zip_code, :string, size: 9, null: false

      add(:is_active, :boolean, default: true, null: false)
      add(:is_blocked, :boolean, default: false, null: false)

      add(
        :company_id,
        references(:companies, type: :binary_id, on_delete: :nothing, on_update: :update_all),
        null: false
      )

      add :deleted_at, :date, null: true, default: nil
      timestamps(inserted_at: :created_at, type: :utc_datetime)
    end

    create index(:customers, [:cpf, :company_id])

    execute "CREATE EXTENSION IF NOT EXISTS pg_trgm;"

    execute """
      CREATE INDEX customers_full_name_gin_trgm_idx
        ON customers
        USING gin (full_name gin_trgm_ops);
    """
  end

  def down do
    drop table(:customers)
  end
end
