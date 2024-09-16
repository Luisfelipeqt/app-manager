defmodule App.Customers do
  import Ecto.Query, warn: false
  require Logger
  alias App.Repo
  alias App.Customers.Customer
  alias App.Accounts.User

  def customers_count(company_id) do
    from(customer in Customer)
    |> where([customer], is_nil(customer.deleted_at))
    |> where([customer], customer.company_id == ^company_id)
    |> Repo.aggregate(:count, :id)
  end

  def paginated_customers(options, company_id) when is_map(options) and is_binary(company_id) do
    from(customer in Customer)
    |> where([customer], is_nil(customer.deleted_at))
    |> where([customer], customer.company_id == ^company_id)
    |> sort(options)
    |> paginate(options)
    |> Repo.all()
  end

  def latest_customers(%User{company_id: company_id}) do
    Customer
    |> where([c], c.company_id == ^company_id)
    |> where([c], is_nil(c.deleted_at))
    |> order_by([c], desc: c.created_at)
    |> limit(10)
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
    |> or_where([c], ilike(c.cpf, ^search_term))
    |> or_where([c], ilike(c.email, ^search_term))
    |> select([c], %{id: c.id, full_name: c.full_name, cpf: c.cpf})
    |> Repo.all()

    # dbg(Ecto.Adapters.SQL.explain(Repo, :all, query))
  end

  defp sort(query, %{sort_by: sort_by, sort_order: sort_order}) do
    order_by(query, {^sort_order, ^sort_by})
  end

  defp sort(query, _options), do: query

  defp paginate(query, %{page: page, per_page: per_page}) do
    offset = max((page - 1) * per_page, 0)

    query
    |> limit(^per_page)
    |> offset(^offset)
  end

  defp paginate(query, _options), do: query
end
