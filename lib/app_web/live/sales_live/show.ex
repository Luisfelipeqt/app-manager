defmodule AppWeb.SalesLive.Show do
  use AppWeb, :live_view
  alias App.Sales
  alias App.Utils

  def mount(_params, _session, socket) do
    socket
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

    sales_count = Sales.sales_count(company_id)

    socket
    |> assign(:options, options)
    |> assign(:sales_count, sales_count)
    |> stream(:paginated_sales, Sales.paginated_sales(options, company_id), reset: true)
    |> noreply()
  end

  def handle_event("select-per-page", %{"per-page" => per_page} = _params, socket) do
    params = %{socket.assigns.options | per_page: per_page}

    socket = push_patch(socket, to: ~p"/vendas/mostrar?#{params}")

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
    <.link patch={~p"/vendas/mostrar?#{@params}"}>
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
       when sort_by in ~w(id which_process total_value which_payment installment is_paid created_at) do
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
end
