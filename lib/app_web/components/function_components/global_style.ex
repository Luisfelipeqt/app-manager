defmodule AppWeb.FunctionComponents.GlobalStyle do
  use Phoenix.Component
  alias Phoenix.LiveView.JS

  use Phoenix.VerifiedRoutes,
    router: AppWeb.Router,
    endpoint: AppWeb.Endpoint

  attr :current_user, :any, required: true
  slot :inner_block, required: true

  def global_style(assigns) do
    ~H"""
    <div class="flex h-screen">
      <aside class="bg-background border-r border-border flex flex-col w-64 shrink-0 p-4">
        <!-- Sidebar content goes here -->
        <.link navigate={~p"/visao-geral"}>
          <img src="/images/e-Gestão.svg" class="" />
        </.link>

        <nav class="flex flex-col gap-2 mt-12">
          <.link
            class="flex items-center gap-3 rounded-md px-3 py-2 text-muted-foreground hover:bg-green-600/75 dark:hover:bg-rose-600/75 hover:text-foreground"
            navigate={~p"/visao-geral"}
          >
            <svg
              xmlns="http://www.w3.org/2000/svg"
              width="24"
              height="24"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              stroke-width="2"
              stroke-linecap="round"
              stroke-linejoin="round"
              class="h-5 w-5"
            >
                <rect width="7" height="9" x="3" y="3" rx="1"></rect>
                <rect
                width="7"
                height="5"
                x="14"
                y="3"
                rx="1"
              ></rect>
                <rect width="7" height="9" x="14" y="12" rx="1"></rect>
                <rect
                width="7"
                height="5"
                x="3"
                y="16"
                rx="1"
              ></rect>
              </svg>Painel de Controle
          </.link>

          <.link
            class="flex items-center gap-3 rounded-md px-3 py-2 text-muted-foreground hover:bg-green-600/75 dark:hover:bg-rose-600/75 hover:text-foreground"
            navigate={~p"/clientes/mostrar"}
          >
            <svg
              xmlns="http://www.w3.org/2000/svg"
              width="24"
              height="24"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              stroke-width="2"
              stroke-linecap="round"
              stroke-linejoin="round"
              class="h-5 w-5"
            >
                <path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"></path>
                <circle
                cx="9"
                cy="7"
                r="4"
              ></circle>
                <path d="M22 21v-2a4 4 0 0 0-3-3.87"></path>
                <path d="M16 3.13a4 4 0 0 1 0 7.75"></path>
              </svg>Clientes
          </.link>

          <.link
            class="flex items-center gap-3 rounded-md px-3 py-2 text-muted-foreground hover:bg-green-600/75 dark:hover:bg-rose-600/75 hover:text-foreground"
            navigate={~p"/vendas/mostrar"}
          >
            <svg
              xmlns="http://www.w3.org/2000/svg"
              width="24"
              height="24"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              stroke-width="2"
              stroke-linecap="round"
              stroke-linejoin="round"
              class="h-5 w-5"
            >
                <line x1="12" x2="12" y1="2" y2="22"></line>
                <path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"></path>
              </svg>Vendas
          </.link>
        </nav>
      </aside>

      <div class="flex flex-col flex-1">
        <header class="h-16 shadow-lg px-4 md:px-6 bg-[#f6f8fa] dark:bg-[#111] flex">
          <!-- Header content goes here -->
          <div class="ml-auto flex w-full max-w-md items-center justify-center">
            <div class=" w-full">
              <.live_component module={AppWeb.LiveComponents.SearchLive} id="searchbar-component" />
            </div>
          </div>

          <div class="ml-auto flex items-center space-x-4">
            <AppWeb.FunctionComponents.ToggleTheme.toggle_theme />
            <div class="relative m-4">
              <div
                class="flex items-center gap-4 cursor-pointer"
                phx-click={JS.toggle_class("hidden", to: "#dropdown-user")}
              >
                <img class="w-10 h-10 rounded-full" src={@current_user.image_url} alt="current user" />
              </div>

              <div
                class="z-50 hidden  text-base list-none divide-y divide-gray-100 rounded shadow top-[100%] right-0 absolute bg-white dark:bg-[#111]"
                id="dropdown-user"
              >
                <div class="px-4 py-3" role="none">
                  <p class="text-sm " role="none">
                    <span class="font-bold text-x">
                      Conectado como
                    </span>
                  </p>

                  <p class="text-sm  " role="none">
                    <%= @current_user.full_name %>
                  </p>

                  <p class="text-sm font-medium  truncate " role="none">
                    <%= @current_user.email %>
                  </p>
                </div>

                <ul class="py-1 divide-y divide-slate-200" role="none">
                  <li>
                    <a
                      href="#"
                      class="block px-4 py-2 text-sm hover:bg-gray-100 dark:md:hover:bg-purple-600"
                      role="menuitem"
                    >
                      Dashboard
                    </a>
                  </li>

                  <li>
                    <a
                      href="#"
                      class="block px-4 py-2 text-sm hover:bg-gray-100 dark:md:hover:bg-purple-600"
                      role="menuitem"
                    >
                      Settings
                    </a>
                  </li>

                  <li>
                    <a
                      href="#"
                      class="block px-4 py-2 text-sm hover:bg-gray-100 dark:md:hover:bg-purple-600"
                      role="menuitem"
                    >
                      Earnings
                    </a>
                  </li>

                  <li>
                    <.link
                      href={~p"/users/log_out"}
                      method="delete"
                      data-confirm="Deseja sair?"
                      class="block px-4 py-2 text-sm hover:bg-gray-100 dark:md:hover:bg-purple-600"
                      role="menuitem"
                    >
                      Sair
                    </.link>
                  </li>
                </ul>
              </div>
            </div>
          </div>
        </header>

        <main class="flex-1 shadow-lg mt-4">
          <!-- Main content goes here -->
          <%= render_slot(@inner_block) %>
        </main>

        <footer class="flex flex-col gap-2 shadow-lg bg-background px-4 py-6 sm:flex-row sm:items-center sm:justify-between md:px-6 bg-[#f6f8fa] dark:bg-[#111]">
          <!-- Footer content goes here -->
          <p class="text-xs text-muted-foreground font-inter">
            © 2024 R-Tech Solutions. Todos os direitos reservados.
          </p>

          <nav class="flex gap-4 sm:gap-6">
            <a class="text-xs hover:underline underline-offset-4 font-inter" href="#">
              Termos de Serviço
            </a>

            <a class="text-xs hover:underline underline-offset-4 font-inter" href="#">
              Política de Privacidade
            </a>

            <a class="text-xs hover:underline underline-offset-4 font-inter" href="#">
              Siga-nos no Twitter
            </a>

            <a class="text-xs hover:underline underline-offset-4 font-inter" href="#">
              Siga-nos no LinkedIn
            </a>
          </nav>
        </footer>
      </div>
    </div>
    """
  end
end
