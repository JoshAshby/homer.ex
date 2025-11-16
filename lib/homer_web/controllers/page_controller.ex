defmodule HomerWeb.PageController do
  use HomerWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
