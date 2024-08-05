defmodule AppWeb.HomeLive.Index do
  use AppWeb, :live_view
  alias App.Sales
  alias App.Customers
  alias App.Utils

  def mount(_params, _session, socket) do
    company_id = socket.assigns.current_user.company_id
    dbg(company_id)

    socket
    |> assign(:page_title, "Visão Geral")
    |> assign_async(:sales_year, fn -> {:ok, %{sales_year: Sales.sales_year(company_id)}} end)
    |> assign_async(:sales_month, fn -> {:ok, %{sales_month: Sales.sales_month(company_id)}} end)
    |> assign_async(:customers_year, fn ->
      {:ok, %{customers_year: Customers.customers_year(company_id)}}
    end)
    |> assign_async(:customers_month, fn ->
      {:ok, %{customers_month: Customers.customers_month(company_id)}}
    end)
    |> assign_async(:most_sold_process_year, fn ->
      {:ok, %{most_sold_process_year: Sales.most_sold_process_year(company_id)}}
    end)
    |> assign_async(:most_sold_process_month, fn ->
      {:ok, %{most_sold_process_month: Sales.most_sold_process_month(company_id)}}
    end)
    |> assign_async(:most_payment_method_year, fn ->
      {:ok, %{most_payment_method_year: Sales.most_payment_method_year(company_id)}}
    end)
    |> assign_async(:most_payment_method_month, fn ->
      {:ok, %{most_payment_method_month: Sales.most_payment_method_month(company_id)}}
    end)
    |> stream(:latest_customers, Customers.latest_customers(company_id), reset: true)
    |> assign(:paginated_sales, [])
    |> assign(:sales_count, Sales.sales_count(company_id))
    |> ok()
  end

  def handle_params(params, _uri, socket) do
    sort_by = valid_sort_by(params)
    sort_order = valid_sort_order(params)

    page = param_to_integer(params["page"], 1)
    per_page = param_to_integer(params["per_page"], 10)

    company_id = socket.assigns.current_user.company_id

    options = %{
      sort_by: sort_by,
      sort_order: sort_order,
      page: page,
      per_page: per_page
    }

    socket
    |> assign(:options, options)
    |> stream(:paginated_sales, Sales.paginated_sales(options, company_id), reset: true)
    |> noreply()
  end

  def handle_event("select-per-page", %{"per-page" => per_page} = _params, socket) do
    params = %{socket.assigns.options | per_page: per_page}

    socket = push_patch(socket, to: ~p"/visao-geral?#{params}")

    {:noreply, socket}
  end

  def sort_link(assigns) do
    params = %{
      assigns.options
      | sort_by: assigns.sort_by,
        sort_order: next_sort_order(assigns.options.sort_order)
    }

    assigns = assign(assigns, params: params)

    ~H"""
    <.link patch={~p"/visao-geral?#{@params}"}>
      <%= render_slot(@inner_block) %>
    </.link>
    """
  end

  defp next_sort_order(sort_order) do
    case sort_order do
      :asc -> :desc
      :desc -> :asc
    end
  end

  defp valid_sort_order(%{"sort_order" => sort_order})
       when sort_order in ~w(asc desc) do
    String.to_atom(sort_order)
  end

  defp valid_sort_order(_params), do: :desc

  defp valid_sort_by(%{"sort_by" => sort_by})
       when sort_by in ~w(id which_process total_value which_payment is_paid installment created_at) do
    String.to_atom(sort_by)
  end

  defp valid_sort_by(_params), do: :created_at

  defp param_to_integer(nil, default), do: default

  defp param_to_integer(param, default) do
    case Integer.parse(param) do
      {number, _} ->
        number

      :error ->
        default
    end
  end

  defp more_pages?(options, sales_count) do
    options.page * options.per_page < sales_count
  end

  defp pages(options, sales_count) do
    page_count = ceil(sales_count / options.per_page)

    for page_number <- (options.page - 2)..(options.page + 2),
        page_number > 0 do
      if page_number <= page_count do
        current_page? = page_number == options.page
        {page_number, current_page?}
      end
    end
  end

  def loading_state(assigns) do
    ~H"""
    <div role="status" class="flex justify-center items-center h-full">
      <svg
        aria-hidden="true"
        class="inline w-10 h-10 text-gray-200 animate-spin dark:text-gray-600 fill-blue-600"
        viewBox="0 0 100 101"
        fill="none"
        xmlns="http://www.w3.org/2000/svg"
      >
        <path
          d="M100 50.5908C100 78.2051 77.6142 100.591 50 100.591C22.3858 100.591 0 78.2051 0 50.5908C0 22.9766 22.3858 0.59082 50 0.59082C77.6142 0.59082 100 22.9766 100 50.5908ZM9.08144 50.5908C9.08144 73.1895 27.4013 91.5094 50 91.5094C72.5987 91.5094 90.9186 73.1895 90.9186 50.5908C90.9186 27.9921 72.5987 9.67226 50 9.67226C27.4013 9.67226 9.08144 27.9921 9.08144 50.5908Z"
          fill="currentColor"
        />
        <path
          d="M93.9676 39.0409C96.393 38.4038 97.8624 35.9116 97.0079 33.5539C95.2932 28.8227 92.871 24.3692 89.8167 20.348C85.8452 15.1192 80.8826 10.7238 75.2124 7.41289C69.5422 4.10194 63.2754 1.94025 56.7698 1.05124C51.7666 0.367541 46.6976 0.446843 41.7345 1.27873C39.2613 1.69328 37.813 4.19778 38.4501 6.62326C39.0873 9.04874 41.5694 10.4717 44.0505 10.1071C47.8511 9.54855 51.7191 9.52689 55.5402 10.0491C60.8642 10.7766 65.9928 12.5457 70.6331 15.2552C75.2735 17.9648 79.3347 21.5619 82.5849 25.841C84.9175 28.9121 86.7997 32.2913 88.1811 35.8758C89.083 38.2158 91.5421 39.6781 93.9676 39.0409Z"
          fill="currentFill"
        />
      </svg>
      <span class="sr-only">Carregando...</span>
    </div>
    """
  end
end
