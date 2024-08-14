defmodule App.Installments do
  import Ecto.Query, warn: false
  require Logger
  alias App.Repo
  alias App.Installments.Installment

  def installments_by_sales_id(sales_id) when is_binary(sales_id) do
    from(installment in Installment)
    |> where([installment], installment.sale_id == ^sales_id)
    |> order_by([i], asc: i.installment_number)
    |> Repo.all()
  end

  def get_installment(id) do
    from(i in Installment)
    |> where([i], i.id == ^id)
    |> order_by([i], asc: i.installment_number)
    |> Repo.one()
  end

  def update_installment(%Installment{} = installment, attrs) do
    installment
    |> Installment.update_changeset(attrs)
    |> Repo.update()
  end
end
