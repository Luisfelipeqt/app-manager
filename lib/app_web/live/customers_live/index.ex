defmodule AppWeb.CustomersLive.Index do
  use AppWeb, :live_view
  alias App.Utils
  alias App.Customers
  alias App.Sales
  alias App.Sales.Sale

  embed_templates "components/*"

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

  def handle_params(params, _uri, socket) do
    socket
    |> apply_action(socket.assigns.live_action, params)
    |> noreply()
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

  def handle_info(
        {AppWeb.LiveComponents.SaleLiveForm, {:sale_created, _}},
        socket
      ) do
    socket
    |> put_flash(:info, "Venda realizada com sucesso.")
    |> push_navigate(to: ~p"/cliente/#{socket.assigns.customer.id}/mostrar", replace: true)
    |> noreply()
  end

  defp apply_action(socket, :new_sale, _params) do
    socket
    |> assign(:page_title, "Nova Venda")
    |> assign(:sale, %Sale{})
  end

  defp apply_action(socket, _, _params) do
    socket
  end
end
