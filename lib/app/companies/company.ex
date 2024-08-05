defmodule App.Companies.Company do
  use Ecto.Schema
  import Ecto.Changeset
  alias App.Accounts.User
  import Brcpfcnpj.Changeset

  @optionals ~w(id created_at updated_at contract_signature_date state number address locality neighborhood image_url)a
  @signature_types ~w(superadmin admin premium basic free)a

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID
  schema "companies" do
    # Informações da empresa
    field(:cnpj, :string)
    field(:contract_signature_date, :date)
    field(:email, :string)
    field(:image_url, :string, default: "/images/default-user.svg")
    field(:trading_name, :string)
    field(:landline_phone, :string)
    field(:legal_name, :string)
    field(:mobile_phone, :string)
    field(:signature, Ecto.Enum, values: @signature_types, default: :basic)

    # Informações do proprietário
    field(:responsible_cpf, :string)
    field(:responsible_name, :string)

    # Informações do endereço
    field(:address, :string)
    field(:locality, :string)
    field(:neighborhood, :string)
    field(:state, :string)
    field(:zip_code, :string)

    # Informações que são booleans
    field(:is_signature_paid, :boolean, default: false)
    field(:is_active, :boolean, default: true)
    field(:is_blocked, :boolean, default: false)

    has_many(:users, User)

    timestamps(inserted_at: :created_at, type: :utc_datetime)
  end

  defp all_fields do
    __MODULE__.__schema__(:fields)
  end

  def create_changeset(company, attrs) do
    company
    |> cast(attrs, all_fields())
    |> validate_required(all_fields() -- @optionals, message: "campo obrigatório")
    |> validate_format(:email, ~r/@/, message: "email inválido")
    |> validate_cnpj(:cnpj, message: "CNPJ inválido")
    |> validate_cpf(:responsible_cpf, message: "CPF inválido")
    |> validate_inclusion(:signature, ~w(premium basic free)a, message: "assinatura inválida")
    |> validate_exclusion(:signature, ~w(superadmin admin)a)
    |> validate_length(:cnpj, min: 14, max: 18, message: "CNPJ inválido")
    |> validate_length(:responsible_cpf, min: 11, max: 14, message: "CPF inválido")
    |> validate_length(:mobile_phone, min: 11, max: 15, message: "número de celular inválido")
    |> validate_length(:state, is: 2, message: "UF inválido")
    |> validate_length(:zip_code, min: 8, max: 9, message: "CEP inválido")
    |> unique_constraint(:cnpj, message: "cnpj já cadastrado!")
    |> unique_constraint(:email, message: "email já cadastrado!")
    |> unique_constraint(:landline_phone, message: "telefone já cadastrado!")
    |> unique_constraint(:responsible_cpf, message: "cpf já cadastrado!")
    |> unique_constraint(:mobile_phone, message: "celular já cadastrado!")
  end
end
