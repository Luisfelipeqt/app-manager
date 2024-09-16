defmodule AppWeb.LiveComponents.SaleLiveForm do
  use AppWeb, :live_component
  require Logger
  alias App.Sales
  alias App.Sales.Sale

  @impl true
  def mount(socket) do
    socket
    |> assign(:customer_id, nil)
    |> assign(:company_id, nil)
    |> assign_form(Sales.change_sale(%Sale{}))
    |> ok()
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
      </.header>
      <br />
      <.form
        :let={f}
        for={@form}
        phx-change="validate"
        phx-submit="save"
        phx-target={@myself}
        autocomplete="off"
      >
        <.input field={f[:total_value]} label="Valor" phx-debounce="blur" />
        <.input
          field={f[:which_payment]}
          type="select"
          label="Tipo de Pagamento"
          options={[
            Pix: :pix,
            Dinheiro: :dinheiro,
            Boleto: :boleto,
            Promissória: :promissoria,
            Débito: :debito,
            Crédito: :credito
          ]}
        />
        <.input field={f[:installment]} type="select" label="Parcelas" options={Enum.to_list(1..12)} />
        <.input
          field={f[:which_process]}
          type="select"
          options={[
            "Adição Categoria B": :adicao_categoria_b,
            "Aula Extra": :aula_extra,
            "Curso Teórico": :curso_teorico,
            "Primeira Habilitação A": :primeira_habilitacao_a,
            "Primeira Habilitação B": :primeira_habilitacao_b,
            "Primeira Habilitação AB": :primeira_habilitacao_ab,
            Reabilitação: :reabilitacao,
            Reciclagem: :reciclagem,
            "Repetência A": :repetencia_a,
            "Repetência B": :repetencia_b,
            "Repetência AB": :repetencia_ab,
            "Repetência Teórica": :repetencia_teorica,
            "Renovação de CNH": :renovacao_cnh,
            Outro: :outro
          ]}
          label="Processo"
          phx-debounce="blur"
        />

        <.input
          field={f[:exemption]}
          type="select"
          options={[Sim: true, Não: false]}
          label="Deseja isentar esta venda?"
          phx-debounce="blur"
          style="margin-top: 16"
        />

        <.input field={f[:customer_id]} type="hidden" value={@customer_id} />
        <.input field={f[:company_id]} type="hidden" value={@company_id} />

        <%!-- <.inputs_for :let={f_nested} field={f[:installments_details]}>
          <.input type="date" field={f_nested[:expiration_date]} />
          <.input type="number" field={f_nested[:installment_number]} />
          <.input type="number" field={f_nested[:value]} />
        </.inputs_for> --%>
        <br />
        <.button phx-disable-with="Salvando...">Salvar</.button>
      </.form>
    </div>
    """
  end

  @impl true
  def handle_event("validate", %{"sale" => sale}, socket) do
    changeset =
      %Sale{}
      |> Sales.change_sale(sale)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset))}
  end

  @impl true
  def handle_event("save", %{"sale" => sale}, socket) do
    save_sale(socket, socket.assigns.action, sale)
  end

  defp save_sale(socket, :new_sale, params) do
    case Sales.create_sale(params) do
      {:ok, sale} ->
        notify_parent({:sale_created, sale})

        changeset = Sales.change_sale(%Sale{})
        {:noreply, assign_form(socket, changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_sale(socket, :sale_edit, params) do
    case Sales.update_sale(socket.assigns.sale, params) do
      {:ok, sale} ->
        notify_parent({:updated_sale, sale})
        changeset = Sales.change_sale(%Sale{})
        {:noreply, assign_form(socket, changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
