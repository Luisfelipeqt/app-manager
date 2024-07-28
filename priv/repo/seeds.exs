# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     App.Repo.insert!(%App.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
r_tech_solutions =
  %App.Companies.Company{
    is_active: true,
    is_blocked: false,
    cnpj: "49.919.215/0001-08",
    email: "felipes@r-solutions.com.br",
    trading_name: "R-Tech",
    legal_name: "R-Tech Solutions",
    mobile_phone: "(16) 99719-8565",
    landline_phone: "(98) 3235-4898",
    responsible_name: "Luis Felipe Rodrigues",
    responsible_cpf: "058.151.473-46",
    is_signature_paid: true,
    contract_signature_date: Date.utc_today(),
    zip_code: "65067-197",
    address: "Rua do Aririzal, Condominio Valência 1, BL 05, APTO 303",
    locality: "São Luis",
    neighborhood: "Cohama",
    state: "MA",
    signature: :admin
  }

solutions_company = App.Repo.insert!(r_tech_solutions)

client_laura = %App.Customers.Customer{
  is_active: true,
  birthday: ~D[2003-12-02],
  cpf: "075.063.473-18",
  email: "lauravitoriasc2@gmail.com",
  full_name: "Laura Vitória Campelo Rodrigues",
  mobile_phone: "(98) 98314-9216",
  gender: :male,
  address: "Rua do Aririzal, Condominio Valência 1, BL 05, APTO 303",
  locality: "São Luis",
  neighborhood: "Cohama",
  state: "MA",
  zip_code: "65067-197",
  company_id: solutions_company.id
}

sale_to_laura = App.Repo.insert!(client_laura)

user_felipe =
  %App.Accounts.User{
    email: "felipe@r-solutions.com.br",
    hashed_password: Argon2.hash_pwd_salt("12345678910a"),
    role: :superadmin,
    company_id: solutions_company.id,
    full_name: "Luis Felipe Rodrigues"
  }

App.Repo.insert!(user_felipe)
