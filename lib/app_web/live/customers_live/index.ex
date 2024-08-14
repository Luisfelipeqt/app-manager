defmodule AppWeb.CustomersLive.Index do
  use AppWeb, :live_view
  alias App.Utils
  alias App.Customers
  alias App.Sales

  def mount(%{"id" => id}, _session, socket) do
    company_id = socket.assigns.current_user.company_id
    customer = Customers.find_customer(id, company_id)
    sales = Sales.find_sales_by_customer_id(id, company_id)

    socket
    |> assign(:page_title, "Detalhes do Cliente")
    |> assign(:customer, customer)
    |> stream(:sales, sales, reset: true)
    |> ok()
  end

  def handle_event("toggle-state", %{"id" => id}, socket) do
    company_id = socket.assigns.current_user.company_id

    sale = Sales.get_sale(id)
    dbg(sale)

    Sales.update_sale(
      sale,
      %{is_paid: !sale.is_paid}
    )

    socket
    |> stream(:sales, Sales.find_sales_by_customer_id(sale.customer_id, company_id), reset: true)
    |> noreply()
  end
end
