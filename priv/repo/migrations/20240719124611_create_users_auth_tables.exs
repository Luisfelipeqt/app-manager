defmodule App.Repo.Migrations.CreateUsersAuthTables do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS citext", ""

    create table(:users) do
      add :email, :citext, null: false
      add :hashed_password, :string, null: false
      add :confirmed_at, :utc_datetime
      add :role, :string, null: false
      add :full_name, :string, null: false
      add :image_url, :string, null: false, default: "/images/default-user.svg"

      add(
        :company_id,
        references(:companies, type: :binary_id, on_delete: :delete_all, on_update: :update_all),
        null: false
      )

      timestamps(inserted_at: :created_at, type: :utc_datetime)
    end

    create unique_index(:users, [:email])

    create table(:users_tokens) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :token, :binary, null: false
      add :context, :string, null: false
      add :sent_to, :string

      timestamps(inserted_at: :created_at, type: :utc_datetime, updated_at: false)
    end

    create index(:users_tokens, [:user_id])
    create unique_index(:users_tokens, [:context, :token])
  end
end
