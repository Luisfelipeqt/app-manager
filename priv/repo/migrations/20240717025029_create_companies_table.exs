defmodule App.Repo.Migrations.CreateCompaniesTable do
  use Ecto.Migration

  def up do
    create table(:companies, primary_key: false) do
      # Company Data
      add :id, :binary_id, null: false, primary_key: true
      add :cnpj, :string, size: 18, null: false
      add :legal_name, :string, null: false
      add :trading_name, :string, null: false
      add :email, :string, null: false
      add :image_url, :string, null: false
      add :mobile_phone, :string, size: 15, null: false
      add :landline_phone, :string, size: 15, null: false, default: "Não informado"
      add :signature, :string, null: false

      # Company Owner Data
      add :responsible_name, :string, null: false
      add :responsible_cpf, :string, size: 14, null: false

      # Company Address Data
      add :address, :string, null: false, default: "Não informado"
      add :locality, :string, null: false, default: "Não informado"
      add :neighborhood, :string, null: false, default: "Não informado"
      add :state, :string, size: 2, null: false, default: "SP"
      add :zip_code, :string, size: 9, null: false

      # Company Payment Data
      add :is_signature_paid, :boolean
      add :is_active, :boolean, null: false, default: true
      add :is_blocked, :boolean, null: false, default: false
      add :deleted_at, :string, null: true, default: nil

      timestamps(inserted_at: :created_at, type: :utc_datetime)
    end

    execute """
      CREATE EXTENSION IF NOT EXISTS pg_trgm;
    """

    execute """
      CREATE INDEX companies_legal_name_gin_trgm_idx ON companies USING gin (legal_name gin_trgm_ops);
    """

    execute """
      CREATE INDEX companies_cnpj_gin_trgm_idx ON companies USING gin (cnpj gin_trgm_ops);
    """

    execute """
      CREATE INDEX companies_trading_name_gin_trgm_idx ON companies USING gin (trading_name gin_trgm_ops);
    """

    execute """
      CREATE INDEX companies_email_gin_trgm_idx ON companies USING gin (email gin_trgm_ops);
    """

    execute """
      CREATE INDEX companies_mobile_phone_gin_trgm_idx ON companies USING gin (mobile_phone gin_trgm_ops);
    """

    execute """
      ALTER TABLE companies ADD CONSTRAINT unique_cnpj UNIQUE (cnpj);
    """

    execute """
      ALTER TABLE companies ADD CONSTRAINT unique_email UNIQUE (email);
    """

    execute """
      ALTER TABLE companies ADD CONSTRAINT unique_mobile_phone UNIQUE (mobile_phone);
    """

    execute """
      ALTER TABLE companies ADD CONSTRAINT unique_landline_phone UNIQUE (landline_phone);
    """

    execute """
      ALTER TABLE companies ADD CONSTRAINT unique_responsible_cpf UNIQUE (responsible_cpf);
    """
  end

  def down do
    drop table(:companies)
  end
end
