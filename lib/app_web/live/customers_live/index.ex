defmodule AppWeb.CustomersLive.Index do
  use AppWeb, :live_view
  alias App.Utils
  alias App.Customers
  alias App.Sales

  def mount(%{"id" => id}, _session, socket) do
    {:ok, customer} = Customers.find_customer(id, socket.assigns.current_user.company_id)
    sales = Sales.sales_by_customer_id(id)
    dbg(id)

    socket
    |> assign(:customer, customer)
    |> stream(:sales, sales)
    |> dbg()
    |> ok()
  end
end
