defmodule AppWeb.HomeLive.Index do
  use AppWeb, :live_view
  alias App.Sales
  alias App.Customers
  alias App.Utils
  alias App.Companies
  alias App.Accounts

  embed_templates "components/*"

  def mount(_params, _session, socket) do
    company_id = socket.assigns.current_user.company_id
    user = socket.assigns.current_user
    timezone = get_connect_params(socket)["timezone"]
    latest_customers = Customers.latest_customers(user)
    latest_sales = Sales.latest_sales(user)

    sales_year = Sales.sales_year(company_id)
    sales_month = Sales.sales_month(company_id)
    customers_year = Customers.customers_year(company_id)
    customers_month = Customers.customers_month(company_id)
    most_sold_process_year = Sales.most_sold_process_year(company_id)
    most_sold_process_month = Sales.most_sold_process_month(company_id)
    most_payment_method_year = Sales.most_payment_method_year(company_id)
    most_payment_method_month = Sales.most_payment_method_month(company_id)

    chart_data_paid = Sales.chart_sold_sales_year_paid(company_id)
    chart_data_not_paid = Sales.chart_sold_sales_year_not_paid(company_id)

    labels_paid =
      Enum.map(chart_data_paid, fn map -> Utils.which_month(Decimal.to_integer(map[:month])) end)
      |> Enum.reject(&is_nil/1)

    values_paid =
      Enum.map(chart_data_paid, fn map -> map[:total_value_sum].amount end)
      |> Enum.reject(&is_nil/1)

    sum_paid =
      Enum.map(chart_data_paid, fn map -> map[:total_value_sum].amount end)
      |> Enum.reject(&is_nil/1)
      |> Enum.sum()

    labels_not_paid =
      Enum.map(chart_data_not_paid, fn map ->
        Utils.which_month(Decimal.to_integer(map[:month]))
      end)
      |> Enum.reject(&is_nil/1)

    values_not_paid =
      Enum.map(chart_data_not_paid, fn map -> map[:total_value_sum].amount end)
      |> Enum.reject(&is_nil/1)

    sum_not_paid =
      Enum.map(chart_data_not_paid, fn map -> map[:total_value_sum].amount end)
      |> Enum.reject(&is_nil/1)
      |> Enum.sum()

    socket
    |> assign(:page_title, "Visão Geral")
    |> assign(:sales_year, sales_year)
    |> assign(:sales_month, sales_month)
    |> assign(:customers_year, customers_year)
    |> assign(:customers_month, customers_month)
    |> assign(:most_sold_process_year, most_sold_process_year)
    |> assign(:most_sold_process_month, most_sold_process_month)
    |> assign(:most_payment_method_year, most_payment_method_year)
    |> assign(:most_payment_method_month, most_payment_method_month)
    |> assign(:timezone, timezone)
    |> stream(:customers, latest_customers, reset: true)
    |> stream(:sales, latest_sales, reset: true)
    |> assign(:sales_count, Sales.sales_count(company_id))
    |> assign(:chart_data_paid, %{
      labels: labels_paid,
      values: values_paid,
      sum: sum_paid,
      color: "#22c55e"
    })
    |> assign(:chart_data_not_paid, %{
      labels: labels_not_paid,
      values: values_not_paid,
      sum: sum_not_paid,
      color: "#ef4444"
    })
    |> ok()
  end

  defp get_name(user) do
    split = String.split(user)
    [first_name, second_name | _] = split
    "#{first_name} #{second_name}"
  end

  defp message_timestamp(message, timezone) do
    message.created_at
    |> Timex.Timezone.convert(timezone)
    |> Timex.format!("%d/%m/%Y às %H:%M", :strftime)
  end

  slot :header, required: true
  slot :section, required: true
  slot :main, required: true
  slot :footer, required: true

  def card_information(assigns) do
    ~H"""
    <div class="rounded-lg border bg-card text-card-foreground shadow-sm" data-v0-t="card">
      <div class="p-6 text-center">
        <h3 class="whitespace-nowrap tracking-tight text-2xl font-medium text-amber-700/75">
          <%= render_slot(@header) %>
        </h3>

        <p class=" text-sm">
          <%= render_slot(@section) %>
        </p>

        <div class="text-2xl font-bold text-green-600">
          <%= render_slot(@main) %>
        </div>

        <p class="text-xs text-muted-foreground">
          <%= render_slot(@footer) %>
        </p>
      </div>
    </div>
    """
  end
end
