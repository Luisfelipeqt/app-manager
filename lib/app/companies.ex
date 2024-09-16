defmodule App.Companies do
  import Ecto.Query, warn: false
  require Logger
  alias App.Repo
  alias App.Companies.Company

  def find_company(company_id) do
    Company
    |> where([c], c.id == ^company_id)
    |> where([c], c.is_blocked == false)
    |> Repo.one()
  end
end
