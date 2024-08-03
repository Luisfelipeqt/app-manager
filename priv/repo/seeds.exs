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

for _ <- 1..5000 do
  customer = %App.Customers.Customer{
    gender: Enum.random(~w(male female non_binary other prefer_not_to_say)a),
    birthday: Faker.Date.between(~D[1924-01-01], ~D[2016-01-01]),
    cpf: Brcpfcnpj.cpf_format(Brcpfcnpj.cpf_generate()),
    email: Faker.Internet.email(),
    full_name: Faker.Person.name(),
    mobile_phone: Faker.Phone.PtBr.phone(),
    image_url: Faker.Avatar.image_url(),
    address: Faker.Address.PtBr.street_name(),
    locality: Faker.Address.PtBr.city(),
    neighborhood: Faker.Address.PtBr.neighborhood(),
    state: Faker.Address.PtBr.state_abbr(),
    zip_code: Faker.Address.PtBr.zip_code(),
    created_at:
      DateTime.truncate(
        Faker.DateTime.between(~U[2016-01-01T00:00:00Z], ~U[2024-08-03T00:00:00Z]),
        :second
      ),
    company_id: solutions_company.id
  }

  customer_inserted = App.Repo.insert!(customer)

  sale = %App.Sales.Sale{
    installment: Enum.random(1..12),
    total_value: Enum.random(8_000..150_000),
    which_payment: Enum.random(~w(boleto credito debito dinheiro pix promissoria)a),
    which_process: Enum.random(~w(
    adicao_categoria_b
    aula_extra
    curso_teorico
    primeira_habilitacao_a
    primeira_habilitacao_b
    primeira_habilitacao_ab
    reabilitacao
    reciclagem
    repetencia_a
    repetencia_b
    repetencia_ab
    repetencia_teorica
    renovacao_cnh
    outro
  )a),
    quantity: Enum.random(1..5),
    is_paid: Enum.random([true, false]),
    created_at:
      DateTime.truncate(
        Faker.DateTime.between(~U[2016-01-01T00:00:00Z], ~U[2024-08-03T00:00:00Z]),
        :second
      ),
    customer_id: customer_inserted.id
  }

  sale_inserted = App.Repo.insert!(sale)
end
