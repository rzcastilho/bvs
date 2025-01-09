defmodule BVS.Jobs.VerifyNewFiles do
  use Oban.Worker

  require Logger

  alias BVS.Jobs.DownloadFile

  alias BVS.{
    FTPServer,
    Negativation
  }

  def perform(%Oban.Job{args: %{"path" => path} = args}) do
    Logger.info("Starting job #{__MODULE__}...\n  -> #{inspect(args)}")

    files =
      path
      |> FTPServer.list_dir()
      |> Enum.filter(&(Negativation.get_return_file_by_name(&1) == nil))
      |> Enum.map(&Negativation.create_return_file(%{name: &1}))
      |> Enum.map(fn {:ok, %{name: name}} ->
        %{path: path, file: name}
        |> DownloadFile.new()
        |> Oban.insert!()

        Path.join(path, name)
      end)

    Logger.debug("New files: #{inspect(files)}")

    Logger.info("Job #{__MODULE__} done!")

    :ok
  end
end
