defmodule BVS.FTPServer do
  use GenServer

  alias BVS.Helpers

  def start_link(origin: :cli) do
    opts =
      case DoIt.Commfig.get(["sftp", "opts"]) do
        nil ->
          IO.puts("The SFTP server was not configured.\nTo continue, inform the configuration...")

          {:ok, config} = Helpers.configure_sftp()
          Enum.to_list(config)

        value ->
          value
          |> Jason.encode!()
          |> Jason.decode!(keys: :atoms)
          |> Enum.to_list()
      end

    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def list_dir(dir) do
    GenServer.call(__MODULE__, {:list_dir, dir})
  end

  def download_file(source_dir, file, target_dir) do
    GenServer.call(__MODULE__, {:download_file, source_dir, file, target_dir})
  end

  def disconnect() do
    GenServer.cast(__MODULE__, :disconnect)
  end

  def init(opts) do
    SFTPClient.connect(opts)
  end

  def handle_call({:list_dir, dir}, _from, conn) do
    {:ok, files} = SFTPClient.list_dir(conn, dir)
    {:reply, files, conn}
  end

  def handle_call({:download_file, source_dir, file, target_dir}, _from, conn) do
    {:ok, file} =
      SFTPClient.download_file(conn, Path.join(source_dir, file), Path.join(target_dir, file))

    {:reply, file, conn}
  end

  def handle_cast(:disconnect, conn) do
    :ok = SFTPClient.disconnect(conn)
    {:stop, :normal, nil}
  end
end
