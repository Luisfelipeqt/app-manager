defmodule App.Repo.Migrations.CreateCustomersTable do
  use Ecto.Migration

  def up do
    create table(:customers, primary_key: false) do
      add :id, :binary_id, null: false, primary_key: true
      add :sex, :string
      add :birthday, :date
      add :cpf, :char, size: 14, null: false
      add :email, :string, null: false
      add :full_name, :string, null: false
      add :phone, :char, size: 15, null: false
      add :registration, :date
      add :image_url, :string, null: false, default: "/images/default-user.svg"

      # Endereço
      add :address, :string, null: false, default: "Não informado"
      add :locality, :string, null: false, default: "Não informado"
      add :neighborhood, :string, null: false, default: "Não informado"
      add :state, :char, size: 2, null: false, default: "SP"
      add :zip_code, :string, size: 9, null: false

      add(:is_active, :boolean, default: true, null: false)

      add(
        :company_id,
        references(:companies, type: :binary_id, on_delete: :delete_all, on_update: :update_all),
        null: false
      )

      add :deleted_at, :string, null: true, default: nil
      timestamps(inserted_at: :created_at, type: :utc_datetime)
    end

    create index(:customers, [:company_id, :cpf])
    create unique_index(:customers, :cpf)
    create unique_index(:customers, :email)
    create unique_index(:customers, :phone)

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
