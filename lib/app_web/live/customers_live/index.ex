defmodule AppWeb.CustomersLive.Index do
  use AppWeb, :live_view
  alias App.Utils
  alias App.Customers
  alias App.Sales

  def mount(%{"id" => id}, _session, socket) do
    company_id = socket.assigns.current_user.company_id
    customer = Customers.find_customer(id, company_id)
    sales = Sales.find_sales_by_customer_id(id, company_id)
    dbg(id)

    socket
    |> assign(:page_title, "Detalhes do Cliente")
    |> assign(:customer, customer)
    |> stream(:sales, sales)
    |> dbg()
    |> ok()
  end
end
