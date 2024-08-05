defmodule AppWeb.LiveComponents.SearchLive do
  use AppWeb, :live_component

  alias App.Customers

  def mount(socket) do
    socket
    |> assign(:search, "")
    |> ok()
  end

  def update(assigns, socket) do
    socket
    |> assign(assigns |> Map.put_new(:search, []))
    |> ok()
  end

  def render(assigns) do
    ~H"""
    <div>
      <div>
        <button
          type="button"
          class="hidden text-gray-500 bg-white hover:ring-gray-500 ring-gray-300 h-8 w-full items-center gap-2 rounded-md pl-2 pr-3 text-sm ring-1 transition lg:flex focus:[&:not(:focus-visible)]:outline-none"
          phx-click={open_modal()}
        >
          <svg viewBox="0 0 20 20" fill="none" aria-hidden="true" class="h-5 w-5 stroke-current">
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              d="M12.01 12a4.25 4.25 0 1 0-6.02-6 4.25 4.25 0 0 0 6.02 6Zm0 0 3.24 3.25"
            >
            </path>
          </svg>
          Buscar
        </button>
        <.text />
      </div>

      <div
        id="searchbar-dialog"
        class="hidden fixed inset-0 z-50"
        role="dialog"
        aria-modal="true"
        phx-window-keydown={hide_modal()}
        phx-key="escape"
      >
        <div class="fixed inset-0 bg-zinc-400/25 backdrop-blur-sm opacity-100"></div>

        <div class="fixed inset-0 overflow-y-auto px-4 py-4 sm:py-20 sm:px-6 md:py-32 lg:px-8 lg:py-[15vh]">
          <div
            id="searchbox_container"
            class="mx-auto overflow-hidden rounded-lg bg-zinc-50 shadow-xl ring-zinc-900/7.5 sm:max-w-xl opacity-100 scale-100"
            phx-hook="SearchBar"
          >
            <div
              role="combobox"
              aria-haspopup="listbox"
              phx-click-away={hide_modal()}
              aria-expanded={@search != []}
            >
              <.form
                for={}
                phx-target={@myself}
                action=""
                novalidate=""
                role="search"
                phx-change="change"
              >
                <div class="group relative flex h-12">
                  <svg
                    viewBox="0 0 20 20"
                    fill="none"
                    aria-hidden="true"
                    class="pointer-events-none absolute left-3 top-0 h-full w-5 stroke-zinc-500"
                  >
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      d="M12.01 12a4.25 4.25 0 1 0-6.02-6 4.25 4.25 0 0 0 6.02 6Zm0 0 3.24 3.25"
                    >
                    </path>
                  </svg>

                  <input
                    id="search-input"
                    name="search[query]"
                    class="flex-auto rounded-lg appearance-none bg-transparent pl-10 text-zinc-900 outline-none focus:outline-none border-slate-200 focus:border-slate-200 focus:ring-0 focus:shadow-none placeholder:text-zinc-500 focus:w-full focus:flex-none sm:text-sm [&::-webkit-search-cancel-button]:hidden [&::-webkit-search-decoration]:hidden [&::-webkit-search-results-button]:hidden [&::-webkit-search-results-decoration]:hidden pr-4"
                    style={
                      @search != [] &&
                        "border-bottom-left-radius: 0; border-bottom-right-radius: 0; border-bottom: none"
                    }
                    aria-autocomplete="both"
                    aria-controls="searchbox__results_list"
                    autocomplete="off"
                    autocorrect="off"
                    autocapitalize="off"
                    enterkeyhint="search"
                    spellcheck="false"
                    placeholder="Buscando algo..."
                    type="search"
                    value=""
                    tabindex="0"
                  />
                </div>

                <ul
                  :if={@search != []}
                  class="divide-y divide-slate-200 overflow-y-auto rounded-b-lg border-t border-slate-200 text-sm leading-6"
                  id="searchbox__results_list"
                  role="listbox"
                >
                  <%= for find <- @search do %>
                    <li id={"#{find.id}"}>
                      <.link
                        navigate={"/cliente/#{find.id}/mostrar"}
                        class="block p-4 hover:bg-slate-300 focus:outline-none focus:bg-slate-100 focus:text-sky-800 dark:text-zinc-900 dark:md:hover:bg-purple-300"
                      >
                        <%= find.full_name %> - <%= find.cpf %>
                      </.link>
                    </li>
                  <% end %>
                </ul>
              </.form>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  attr :text, :string, default: ""

  def text(assigns) do
    ~H"""
    <p class="text-xs text-gray-500 mt-1"><%= @text %></p>
    """
  end

  def handle_event("change", %{"search" => %{"query" => ""}}, socket) do
    socket
    |> assign(:search, [])
    |> noreply()
  end

  def handle_event("change", %{"search" => %{"query" => search_query}}, socket) do
    socket
    |> assign(:search, Customers.search(search_query))
    |> noreply()
  end

  def open_modal(js \\ %JS{}) do
    js
    |> JS.show(
      to: "#searchbox_container",
      transition:
        {"transition ease-out duration-200", "opacity-0 scale-95", "opacity-100 scale-100"}
    )
    |> JS.show(
      to: "#searchbar-dialog",
      transition: {"transition ease-in duration-100", "opacity-0", "opacity-100"}
    )
    |> JS.focus(to: "#search-input")
  end

  def hide_modal(js \\ %JS{}) do
    js
    |> JS.hide(
      to: "#searchbar-searchbox_container",
      transition:
        {"transition ease-in duration-100", "opacity-100 scale-100", "opacity-0 scale-95"}
    )
    |> JS.hide(
      to: "#searchbar-dialog",
      transition: {"transition ease-in duration-100", "opacity-100", "opacity-0"}
    )
  end
end
