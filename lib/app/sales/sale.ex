defmodule App.Sales.Sale do
  use Ecto.Schema
  import Ecto.Changeset
  alias App.Customers.Customer

  @optionals ~w(id created_at updated_at)a
  @which_payment ~w(boleto credito debito dinheiro pix promissoria)a
  @which_process ~w(
    adicao_categoria_b
    aula_extra
    curso_teorico
    primeira_habilitacao_a
    primeira_habilitacao_b
    primeira_habilitacao_ab
    reabilitacao
    reciclagem
    repetencia_a
    repetencia_b
    repetencia_ab
    repetencia_teorica
    renovacao_cnh
    outro
  )a

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID
  schema "sales" do
    field(:installment, :integer, default: 1)
    field(:total_value, Money.Ecto.Amount.Type)
    field(:exemption, :boolean, default: false)
    field(:which_payment, Ecto.Enum, values: @which_payment)
    field(:which_process, Ecto.Enum, values: @which_process)
    field(:quantity, :integer, default: 1)
    field(:is_paid, :boolean, default: false)

    has_many(:installments, Installment)
    belongs_to(:customer, Customer, foreign_key: :customer_id)

    timestamps(inserted_at: :created_at, type: :utc_datetime)
  end

  defp all_fields do
    __MODULE__.__schema__(:fields)
  end

  def create_changeset(sale, attrs) do
    sale
    |> cast(attrs, all_fields())
    |> validations(all_fields() -- @optionals)
    |> cast_assoc(:installments, with: &Installment.create_changeset/2)
    |> assoc_constraint(:customer, message: "cliente não encontrado")
  end

  defp validations(changeset, attrs) do
    changeset
    |> validate_required(attrs, message: "campo obrigatório")
    |> validate_money(:total_value)
    |> validate_number(:quantity, greater_than: 0)
    |> validate_number(:installment, greater_than: 0)
    |> validate_inclusion(:which_payment, @which_payment, message: "método de pagamento inválido")
    |> validate_inclusion(:which_process, @which_process, message: "processo inválido")
    |> validate_inclusion(:is_paid, [true, false])
    |> validate_inclusion(:exemption, [true, false])
  end

  defp validate_money(changeset, field) do
    validate_change(changeset, field, fn
      _, %Money{amount: amount} when amount > 0 -> []
      _, _ -> [amount: "must be greater than 0"]
    end)
  end
end
