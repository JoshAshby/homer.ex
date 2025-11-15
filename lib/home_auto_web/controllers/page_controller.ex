defmodule HomeAutoWeb.PageController do
  use HomeAutoWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
