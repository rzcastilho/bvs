defmodule BVS.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      BVSWeb.Telemetry,
      BVS.Repo,
      {BVS.FTPServer, Application.get_env(:bvs, :sftp)},
      {Oban, Application.fetch_env!(:bvs, Oban)},
      {Phoenix.PubSub, name: BVS.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: BVS.Finch},
      # Start a worker by calling: BVS.Worker.start_link(arg)
      # {BVS.Worker, arg},
      # Start to serve requests, typically the last entry
      BVSWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: BVS.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BVSWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
