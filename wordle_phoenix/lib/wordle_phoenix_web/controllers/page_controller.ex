defmodule WordlePhoenixWeb.PageController do
  use WordlePhoenixWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

end
