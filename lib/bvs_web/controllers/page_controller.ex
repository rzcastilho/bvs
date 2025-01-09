defmodule BVSWeb.PageController do
  use BVSWeb, :controller

  def home(conn, _params) do
    redirect(conn, to: ~p"/return_files")
  end
end
