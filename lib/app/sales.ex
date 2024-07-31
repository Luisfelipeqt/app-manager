defmodule App.Sales do
  import Ecto.Query, warn: false
  require Logger
  alias App.Repo
  alias App.Sales.Sale

  def sales_by_customer_id(customer_id)  do
    from(s in Sale)
    |> join(:left, [s], c in assoc(s, :customer))
    |> where([s, c], s.customer_id == ^customer_id)
    |> select(
      [s, c],
      %{
        value: s.total_value,
        installment: s.installment,
        which_payment: s.which_payment,
        which_process: s.which_process,
        is_paid: s.is_paid,
        id: s.id,
        created_at: s.created_at,
        customer_name: c.full_name,
        customer_phone: c.mobile_phone,
        customer_email: c.email,
        customer_image: c.image_url,
        customer_cpf: c.cpf,
        customer_id: c.id
      }
    )
    |> order_by([s], desc: s.created_at)
    |> Repo.all()
  end

  def sales_by_company_id(""), do: []

  def sales_by_company_id(options, company_id) when is_map(options) do
    from(s in Sale)
    |> join(:left, [s], c in assoc(s, :customer))
    |> select(
      [s, c],
      %{
        id: s.id,
        customer_name: c.full_name,
        which_process: s.which_process,
        total_value: s.total_value,
        which_payment: s.which_payment,
        is_paid: s.is_paid,
        created_at: s.created_at
      }
    )
    |> where([s, c], c.company_id == ^company_id)
    |> sort(options)
    |> paginate(options)
    |> Repo.all()
  end

  def most_payment_method(company_id) do
    from(s in Sale)
    |> select([s], %{count_payment: count(s.which_payment), which_payment: s.which_payment})
    |> join(:left, [s], c in assoc(s, :customer))
    |> where([s, c], c.company_id == ^company_id and s.exemption == false)
    |> group_by([s], s.which_payment)
    |> order_by([s], desc: count(s.which_payment))
    |> limit(1)
    |> Repo.one()
  end

  def most_sold_process(company_id) do
    from(s in Sale)
    |> join(:left, [s], c in assoc(s, :customer))
    |> where([s, c], c.company_id == ^company_id and s.exemption == false)
    |> group_by([s], s.which_process)
    |> order_by([s], desc: count(s.which_process))
    |> select([s], %{count_process: count(s.which_process), which_process: s.which_process})
    |> limit(1)
    |> Repo.one()
  end

  def sales_year(company_id) do
    from(s in Sale)
    |> join(:left, [s], c in assoc(s, :customer))
    |> where(
      [s, c],
      c.company_id == ^company_id and s.exemption == false
    )
    |> Repo.aggregate(:sum, :total_value)
  end

  def sales_month(company_id, days \\ 31) do
    from(s in Sale)
    |> join(:left, [s], c in assoc(s, :customer))
    |> where(
      [s, c],
      c.company_id == ^company_id and s.exemption == false
    )
    |> where(
      [c, s],
      fragment("? - ? <= ? * interval '1 day'", ^NaiveDateTime.utc_now(), c.created_at, ^days)
    )
    |> Repo.aggregate(:sum, :total_value)
  end

  def get_sale!(sale_id) do
    from(s in Sale)
    |> join(:left, [s], c in assoc(s, :customer))
    |> where([s], s.id == ^sale_id)
    |> order_by([s], desc: s.created_at)
    |> Repo.one()
  end

  def update_sale(%Sale{} = sale, attrs) do
    sale
    |> Sale.updated_changeset(attrs)
    |> Repo.update()
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
