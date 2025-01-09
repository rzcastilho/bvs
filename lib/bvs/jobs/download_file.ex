defmodule BVS.Jobs.DownloadFile do
  use Oban.Worker

  require Logger

  alias BVS.Jobs.ProcessFile

  alias BVS.{
    FTPServer,
    Negativation
  }

  def perform(%Oban.Job{args: %{"path" => path, "file" => file} = args}) do
    Logger.info("Starting job #{__MODULE__}...\n  -> #{inspect(args)}")

    downloaded_file =
      FTPServer.download_file(path, file, System.tmp_dir!())

    {:ok, return_file} = Negativation.update_return_file_status_by_name(file, :downloaded)

    {:ok, _job} =
      %{id: return_file.id, file: downloaded_file}
      |> ProcessFile.new()
      |> Oban.insert()

    Logger.debug("Downloaded file: #{inspect(downloaded_file)}")

    Logger.info("Job #{__MODULE__} done!")

    :ok
  end
end
