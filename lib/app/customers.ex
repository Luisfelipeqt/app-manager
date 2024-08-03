defmodule App.Customers do
  import Ecto.Query, warn: false
  require Logger
  alias App.Repo
  alias App.Customers.Customer

  def latest_customers(company_id) do
    from(c in Customer)
    |> where([c], c.company_id == ^company_id)
    |> where([c], is_nil(c.deleted_at))
    |> order_by([c], desc: c.created_at)
    |> limit(8)
    |> Repo.all()
  end

  def customers_year(company_id) do
    start_of_year = Timex.beginning_of_year(NaiveDateTime.utc_now())
    end_of_year = Timex.end_of_year(NaiveDateTime.utc_now())

    from(c in Customer)
    |> where([c], c.company_id == ^company_id)
    |> where([c], c.created_at >= ^start_of_year and c.created_at <= ^end_of_year)
    |> Repo.aggregate(:count, :company_id)
  end

  def customers_month(company_id) do
    start_of_month = Timex.beginning_of_month(NaiveDateTime.utc_now())
    end_of_month = Timex.end_of_month(NaiveDateTime.utc_now())

    from(c in Customer)
    |> where([c], c.company_id == ^company_id)
    |> where([c], c.created_at >= ^start_of_month and c.created_at <= ^end_of_month)
    |> Repo.aggregate(:count, :company_id)
  end

  def find_all_customers(company_id) do
    from(c in Customer)
    |> where([c], c.company_id == ^company_id)
    |> where([c], is_nil(c.deleted_at))
    |> Repo.all()
  end

  def find_customer(customer_id, company_id) do
    from(c in Customer)
    |> where([c], c.id == ^customer_id)
    |> where([c], c.company_id == ^company_id)
    |> where([c], is_nil(c.deleted_at))
    |> Repo.one()
  end

  # def delete_customer(cpf, company_id) do
  # customer = find_customer(cpf, company_id)

  #  case customer do
  #   {:ok, customer} ->
  #     Customer.delete_changeset(customer) |> Repo.update()
  #     Logger.info("Customer deleted: #{inspect(customer.full_name)}")

  #  {:error, e} ->
  #    Logger.error("Error deleting customer: #{inspect(e)}")
  # end
  # end

  def search(""), do: []

  def search(search_term) do
    search_term = "%#{search_term}%"

    from(c in Customer)
    |> where([c], ilike(c.full_name, ^search_term))
    |> select([c], %{id: c.id, full_name: c.full_name, cpf: c.cpf})
    |> Repo.all()
  end
end
