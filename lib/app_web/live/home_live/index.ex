defmodule AppWeb.HomeLive.Index do
  use AppWeb, :live_view

  def mount(_params, _session, socket) do
    socket
    |> ok()
  end
end
