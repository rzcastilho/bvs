defmodule BVSWeb.Router do
  use BVSWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {BVSWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", BVSWeb do
    pipe_through :browser

    get "/", PageController, :home

    live "/return_codes", ReturnCodeLive.Index, :index
    live "/return_codes/new", ReturnCodeLive.Index, :new
    live "/return_codes/:id/edit", ReturnCodeLive.Index, :edit

    live "/return_codes/:id", ReturnCodeLive.Show, :show
    live "/return_codes/:id/show/edit", ReturnCodeLive.Show, :edit

    live "/return_files", ReturnFileLive.Index, :index
    live "/return_files/new", ReturnFileLive.Index, :new
    live "/return_files/:id/edit", ReturnFileLive.Index, :edit
    live "/return_files/:id/errors", ReturnFileLive.Index, :errors

    live "/return_files/:id", ReturnFileLive.Show, :show
    live "/return_files/:id/show/edit", ReturnFileLive.Show, :edit

    live "/ocurrence_types", OcurrenceTypeLive.Index, :index
    live "/ocurrence_types/new", OcurrenceTypeLive.Index, :new
    live "/ocurrence_types/:id/edit", OcurrenceTypeLive.Index, :edit

    live "/ocurrence_types/:id", OcurrenceTypeLive.Show, :show
    live "/ocurrence_types/:id/show/edit", OcurrenceTypeLive.Show, :edit

    live "/items", ItemLive.Index, :index
    live "/items/new", ItemLive.Index, :new
    live "/items/:id/edit", ItemLive.Index, :edit

    live "/items/:id", ItemLive.Show, :show
    live "/items/:id/show/edit", ItemLive.Show, :edit
  end

  # Other scopes may use custom stacks.
  # scope "/api", BVSWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:bvs, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: BVSWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
