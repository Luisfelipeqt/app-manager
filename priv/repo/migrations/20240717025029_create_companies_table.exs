defmodule App.Repo.Migrations.CreateCompaniesTable do
  use Ecto.Migration

  def up do
    create table(:companies) do
      add :cnpj, :string, size: 18, null: false
      add :contract_signature_date, :date
      add :email, :string, null: false
      add :image_url, :string, default: "/images/default-user.svg"
      add :trading_name, :string, null: false
      add :landline_phone, :string, size: 20, null: false, default: "Não informado"
      add :legal_name, :string, null: false
      add :mobile_phone, :string, size: 20, null: false
      add :signature, :string, null: false

      # Company Owner Data
      add :responsible_cpf, :string, size: 14, null: false
      add :responsible_name, :string, null: false

      # Company Address Data
      add :address, :string, null: false, default: "Não informado"
      add :locality, :string, null: false, default: "Não informado"
      add :neighborhood, :string, null: false, default: "Não informado"
      add :state, :string, size: 2, null: false, default: "SP"
      add :zip_code, :string, size: 10, null: false

      # Company Payment Data
      add :is_signature_paid, :boolean, default: false
      add :is_active, :boolean, null: false, default: true
      add :is_blocked, :boolean, null: false, default: false

      timestamps(inserted_at: :created_at, type: :utc_datetime)
    end

    create unique_index(:companies, :cnpj)
    create unique_index(:companies, :email)
    create unique_index(:companies, :mobile_phone)
    create unique_index(:companies, :landline_phone)
    create unique_index(:companies, :responsible_cpf)

    execute """
      CREATE EXTENSION IF NOT EXISTS pg_trgm;
    """

    execute """
      CREATE INDEX companies_legal_name_gin_trgm_idx ON companies USING gin (legal_name gin_trgm_ops);
    """
  end

  def down do
    drop table(:companies)
  end
end
