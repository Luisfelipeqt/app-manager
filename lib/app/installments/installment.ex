defmodule App.Installments.Installment do
  use Ecto.Schema
  import Ecto.Changeset
  alias App.Sales.Sale

  @optionals ~w(id created_at updated_at)a

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID
  schema "installments" do
    field(:expiration_date, :date, default: Date.add(Date.utc_today(), 30))
    field(:installment_number, :integer, default: 1)
    field(:value, Money.Ecto.Amount.Type)
    field(:is_paid, :boolean, default: false)

    belongs_to(:sale, Sale, foreign_key: :sale_id)
    timestamps(inserted_at: :created_at, type: :utc_datetime)
  end

  defp all_fields do
    __MODULE__.__schema__(:fields)
  end

  def create_changeset(installment, attrs) do
    installment
    |> cast(attrs, all_fields())
    |> validate_required(all_fields() -- @optionals)
    |> validate_money(:value)
    |> validate_number(:installment_number, greater_than: 0)
    |> assoc_constraint(:sale, message: "venda não encontrada")
  end

  def update_changeset(installment, attrs) do
    installment
    |> cast(attrs, all_fields())
  end

  defp validate_money(changeset, field) do
    validate_change(changeset, field, fn
      _, %Money{amount: amount} when amount > 0 -> []
      _, _ -> [amount: "must be greater than 0"]
    end)
  end
end
