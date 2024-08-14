defmodule App.Sales do
  import Ecto.Query, warn: false
  require Logger
  alias App.Repo
  alias App.Sales.Sale
  alias App.Installments.Installment

  def create_sale(attrs \\ %{}) do
    {:ok, total_value} = Money.parse(attrs["total_value"], :BRL)

    attrs = %{
      attrs
      | "total_value" => total_value.amount,
        "installment" => attrs["installment"],
        "customer_id" => attrs["customer_id"]
    }

    Repo.transaction(fn ->
      {:ok, sale} =
        %Sale{}
        |> Sale.create_changeset(attrs)
        |> Repo.insert()

      total_value_in_cents = total_value.amount
      installment_count = String.to_integer(attrs["installment"])

      installment_value_in_cents =
        Money.divide(Money.new(total_value_in_cents), installment_count)
        |> List.last()
        |> Map.get(:amount)

      Enum.each(1..installment_count, fn installment_number ->
        expiration_date = Date.add(Date.utc_today(), installment_number * 31)

        %Installment{}
        |> Installment.create_changeset(%{
          sale_id: sale.id,
          installment_number: installment_number,
          value: installment_value_in_cents,
          expiration_date: expiration_date
        })
        |> Repo.insert()
      end)
    end)
  end

  def sales_count(company_id) do
    from(sale in Sale)
    |> join(:left, [sale], customer in assoc(sale, :customer))
    |> where([sale], sale.exemption == false)
    |> where([_, customer], customer.company_id == ^company_id)
    |> Repo.aggregate(:count, :id)
  end

  def paginated_sales(options, company_id) when is_map(options) do
    from(sale in Sale)
    |> join(:left, [sale], customer in assoc(sale, :customer))
    |> select(
      [sale, customer],
      %{
        id: sale.id,
        sale_process: sale.which_process,
        sale_value: sale.total_value,
        sale_payment: sale.which_payment,
        sale_paid: sale.is_paid,
        sale_created_at: sale.created_at,
        sale_installment: sale.installment,
        customer_name: customer.full_name,
        customer_mobile_phone: customer.mobile_phone
      }
    )
    |> where([sale, customer], customer.company_id == ^company_id)
    |> sort(options)
    |> paginate(options)
    |> Repo.all()
  end

  def find_sales_by_customer_id(customer_id, company_id) do
    from(s in Sale)
    |> join(:left, [s], c in assoc(s, :customer))
    |> select(
      [s, c],
      %{
        id: s.id,
        customer_name: c.full_name,
        customer_mobile_phone: c.mobile_phone,
        which_process: s.which_process,
        total_value: s.total_value,
        which_payment: s.which_payment,
        is_paid: s.is_paid,
        created_at: s.created_at,
        installment: s.installment
      }
    )
    |> where([s, _], s.customer_id == ^customer_id)
    |> where([_, c], c.company_id == ^company_id)
    |> order_by([s], desc: s.created_at)
    |> Repo.all()
  end

  def latest_sales(company_id) do
    from(s in Sale)
    |> join(:left, [s], c in assoc(s, :customer))
    |> select(
      [s, c],
      %{
        id: s.id,
        customer_name: c.full_name,
        customer_mobile_phone: c.mobile_phone,
        which_process: s.which_process,
        total_value: s.total_value,
        which_payment: s.which_payment,
        is_paid: s.is_paid,
        created_at: s.created_at,
        installment: s.installment
      }
    )
    |> where([s, c], c.company_id == ^company_id)
    |> order_by([s], desc: s.created_at)
    |> limit(5)
    |> Repo.all()
  end

  def most_payment_method_year(company_id) do
    start_of_year = Timex.beginning_of_year(NaiveDateTime.utc_now())
    end_of_year = Timex.end_of_year(NaiveDateTime.utc_now())

    from(s in Sale)
    |> select([s], %{count_payment: count(s.which_payment), which_payment: s.which_payment})
    |> join(:left, [s], c in assoc(s, :customer))
    |> where([s, c], c.company_id == ^company_id and s.exemption == false)
    |> where([s], s.exemption == false)
    |> where([c], c.created_at >= ^start_of_year and c.created_at <= ^end_of_year)
    |> group_by([s], s.which_payment)
    |> order_by([s], desc: count(s.which_payment))
    |> limit(1)
    |> Repo.one()
  end

  def most_payment_method_month(company_id) do
    start_of_month = Timex.beginning_of_month(NaiveDateTime.utc_now())
    end_of_month = Timex.end_of_month(NaiveDateTime.utc_now())

    from(s in Sale)
    |> select([s], %{count_payment: count(s.which_payment), which_payment: s.which_payment})
    |> join(:left, [s], c in assoc(s, :customer))
    |> where([s, c], c.company_id == ^company_id and s.exemption == false)
    |> where([s], s.exemption == false)
    |> where([c], c.created_at >= ^start_of_month and c.created_at <= ^end_of_month)
    |> group_by([s], s.which_payment)
    |> order_by([s], desc: count(s.which_payment))
    |> limit(1)
    |> Repo.one()
  end

  def most_sold_process_year(company_id) do
    start_of_year = Timex.beginning_of_year(NaiveDateTime.utc_now())
    end_of_year = Timex.end_of_year(NaiveDateTime.utc_now())

    from(s in Sale)
    |> join(:left, [s], c in assoc(s, :customer))
    |> where([s, c], c.company_id == ^company_id and s.exemption == false)
    |> where([s], s.exemption == false)
    |> where([c], c.created_at >= ^start_of_year and c.created_at <= ^end_of_year)
    |> group_by([s], s.which_process)
    |> order_by([s], desc: count(s.which_process))
    |> select([s], %{count_process: count(s.which_process), which_process: s.which_process})
    |> limit(1)
    |> Repo.one()
  end

  def most_sold_process_month(company_id) do
    start_of_month = Timex.beginning_of_month(NaiveDateTime.utc_now())
    end_of_month = Timex.end_of_month(NaiveDateTime.utc_now())

    from(s in Sale)
    |> join(:left, [s], c in assoc(s, :customer))
    |> where([s, c], c.company_id == ^company_id and s.exemption == false)
    |> where([s], s.exemption == false)
    |> where([c], c.created_at >= ^start_of_month and c.created_at <= ^end_of_month)
    |> group_by([s], s.which_process)
    |> order_by([s], desc: count(s.which_process))
    |> select([s], %{count_process: count(s.which_process), which_process: s.which_process})
    |> limit(1)
    |> Repo.one()
  end

  def sales_year(company_id) do
    start_of_year = Timex.beginning_of_year(NaiveDateTime.utc_now())
    end_of_year = Timex.end_of_year(NaiveDateTime.utc_now())

    from(s in Sale)
    |> join(:left, [s], c in assoc(s, :customer))
    |> where([s, c], c.company_id == ^company_id)
    |> where([s], s.exemption == false)
    |> where([s], s.created_at >= ^start_of_year and s.created_at <= ^end_of_year)
    |> Repo.aggregate(:sum, :total_value)
  end

  def sales_month(company_id) do
    start_of_month = Timex.beginning_of_month(NaiveDateTime.utc_now())
    end_of_month = Timex.end_of_month(NaiveDateTime.utc_now())

    from(s in Sale)
    |> join(:left, [s], c in assoc(s, :customer))
    |> where([s], s.exemption == false)
    |> where([s, c], c.company_id == ^company_id and s.exemption == false)
    |> where([c], c.created_at >= ^start_of_month and c.created_at <= ^end_of_month)
    |> Repo.aggregate(:sum, :total_value)
  end

  def get_sale(sale_id, company_id) do
    from(s in Sale)
    |> join(:left, [s], c in assoc(s, :customer))
    |> where([s], s.id == ^sale_id)
    |> where([s], s.exemption == false)
    |> where([_, c], c.company_id == ^company_id)
    |> where([_, c], is_nil(c.deleted_at))
    |> select(
      [s, c],
      %{
        customer_id: c.id,
        customer_name: c.full_name,
        customer_mobile_phone: c.mobile_phone,
        customer_email: c.email,
        customer_address: c.address,
        customer_locality: c.locality,
        customer_neighborhood: c.neighborhood,
        customer_state: c.state,
        sale_id: s.id,
        sale_created_at: s.created_at,
        sale_value: s.total_value,
        sale_installment: s.installment,
        sale_payment: s.which_payment,
        sale_paid: s.is_paid,
        sale_quantity: s.quantity,
        sale_process: s.which_process
      }
    )
    |> Repo.one()
  end

  def get_sale(sale_id) do
    from(s in Sale)
    |> where([s], s.id == ^sale_id)
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
