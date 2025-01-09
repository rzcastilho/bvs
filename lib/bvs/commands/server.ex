defmodule BVS.Commands.Server do
  use DoIt.Command,
    description: "Starts the BVS application."

  alias BVS.Helpers

  def run(_, _, %{config: %{"configured" => true, "sftp" => %{"dir" => dir}}}) do
    with {:ok, _} <- BVS.Application.start(:normal, []),
         :ok <- Helpers.browser_open("http://localhost:4000/return_files") do
      IO.puts("Press 'CTRL+C' to exit...")

      BVS.Jobs.VerifyNewFiles.new(%{path: dir})
      |> Oban.insert()

      Process.sleep(:infinity)
    else
      error ->
        IO.inspect(error)
    end
  end

  def run(_, _, _) do
    Helpers.configure_cli()
  end
end
