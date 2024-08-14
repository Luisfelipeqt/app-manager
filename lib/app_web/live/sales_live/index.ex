defmodule AppWeb.SalesLive.Index do
  use AppWeb, :live_view
  alias App.Sales
  alias App.Utils
  alias App.Installments

  def mount(%{"id" => sale_id}, _, socket) do
    %{current_user: current_user} = socket.assigns
    sale = Sales.get_sale(sale_id, current_user.company_id)
    installments = Installments.installments_by_sales_id(sale.sale_id)
    dbg(current_user.company_id)

    socket
    |> assign(:sale, sale)
    |> assign(:installments, installments)
    |> ok()
  end

  def handle_event("toggle-state", %{"id" => id}, socket) do
    installment = Installments.get_installment(id)

    {:ok, updated_installment} =
      Installments.update_installment(installment, %{is_paid: !installment.is_paid})

    installments =
      Enum.map(socket.assigns.installments, fn i ->
        if updated_installment.id == i.id do
          updated_installment
        else
          i
        end
      end)

    socket
    |> assign(:installments, installments)
    |> noreply()
  end
end
