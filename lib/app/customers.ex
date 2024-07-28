defmodule App.Customers do
  import Ecto.Query, warn: false
  require Logger
  alias App.Repo
  alias App.Customers.Customer

  def find_all_customers(company_id) do
    from(c in Customer)
    |> where([c], c.company_id == ^company_id)
    |> where([c], is_nil(c.deleted_at))
    |> Repo.all()
    |> case do
      [] -> {:error, "No customers found"}
      customers -> {:ok, customers}
    end
  end

  def find_customer(cpf, company_id) do
    from(c in Customer)
    |> where([c], c.cpf == ^cpf and c.company_id == ^company_id)
    |> where([c], is_nil(c.deleted_at))
    |> Repo.one()
    |> case do
      nil -> {:error, "Customer not found"}
      customer -> {:ok, customer}
    end
  end

  def delete_customer(cpf, company_id) do
    customer = find_customer(cpf, company_id)

    case customer do
      {:ok, customer} ->
        Customer.delete_changeset(customer) |> Repo.update()
        Logger.info("Customer deleted: #{inspect(customer.full_name)}")

      {:error, e} ->
        Logger.error("Error deleting customer: #{inspect(e)}")
    end
  end

  def search(""), do: []

  def search(search_term) do
    search_term = "%#{search_term}%"

    from(c in Customer)
    |> where([c], ilike(c.full_name, ^search_term))
    |> select([c], %{id: c.id, full_name: c.full_name, cpf: c.cpf})
    |> Repo.all()
  end
end
