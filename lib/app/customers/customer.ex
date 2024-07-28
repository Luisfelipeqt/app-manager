defmodule App.Customers.Customer do
  use Ecto.Schema
  import Ecto.Changeset
  import Brcpfcnpj.Changeset
  alias App.Companies.Company
  alias App.Sales.Sale

  @optionals ~w(id created_at updated_at state address locality neighborhood number)a

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID
  schema "customers" do
    # Informações do cliente
    field(:gender, Ecto.Enum, values: ~w(male female non_binary other prefer_not_to_say)a)
    field(:birthday, :date)
    field(:cpf, :string)
    field(:email, :string)
    field(:full_name, :string)
    field(:mobile_phone, :string)
    field(:registration, :date)
    field(:image_url, :string, default: "/images/default-user.svg")

    # Informações do endereço
    field(:address, :string)
    field(:locality, :string)
    field(:neighborhood, :string)
    field(:state, :string)
    field(:zip_code, :string)

    # Informações booleanos
    field(:is_active, :boolean, default: true)
    field(:is_blocked, :boolean, default: false)
    field(:deleted_at, :date, default: nil)

    has_many(:sales, Sale)
    belongs_to(:company, Company, foreign_key: :company_id)

    timestamps(inserted_at: :created_at, type: :utc_datetime)
  end

  defp all_fields do
    __MODULE__.__schema__(:fields)
  end

  @doc false
  def create_changeset(client, attrs) do
    client
    |> cast(attrs, all_fields())
    |> validations(all_fields() -- @optionals)
    |> unique_constraint(:cpf, message: "cpf já cadastrado!")
    |> unique_constraint(:email, message: "email já cadastrado!")
    |> unique_constraint(:mobile_phone, message: "celular já cadastrado!")
    |> cast_assoc(:sales, with: &Sale.create_changeset/2)
    |> assoc_constraint(:company, message: "empresa não encontrada")
  end

  defp validations(changeset, attrs) do
    changeset
    |> validate_required(attrs, message: "campo obrigatório")
    |> validate_cpf(:cpf, message: "CPF inválido")
    |> validate_format(:email, ~r/@/, message: "email inválido")
    |> validate_length(:full_name, min: 2, max: 200, message: "muito curto ou muito longo")
    |> validate_length(:cpf, min: 11, max: 14, message: "CPF inválido")
    |> validate_length(:mobile_phone, min: 11, max: 15, message: "número de celular inválido")
    |> validate_length(:state, is: 2, message: "UF inválido")
    |> validate_length(:zip_code, min: 8, max: 9, message: "CEP inválido")
    |> validate_inclusion(:gender, ~w(male female non_binary other prefer_not_to_say)a,
      message: "sexo inválido"
    )
  end

  def delete_changeset(customer) do
    change(customer)
    |> put_change(:deleted_at, NaiveDateTime.utc_now(:second))
    |> put_change(:email, "anonimizado#{System.unique_integer()}@anonimizado.com")
    |> put_change(:is_active, false)
  end
end
