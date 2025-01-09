defmodule BVS.Helpers do
  require Logger

  @app :bvs

  def timestamp_from_filename(<<
        _prefix::binary-3,
        year::binary-4,
        month::binary-2,
        day::binary-2,
        hour::binary-2,
        minute::binary-2,
        second::binary-2,
        _gmt::binary-4,
        _rest::binary
      >>) do
    "#{year}-#{month}-#{day} #{hour}:#{minute}:#{second}"
  end

  def browser_open(url) do
    win_cmd_args = ["/c", "start", String.replace(url, "&", "^&")]

    cmd_args =
      case :os.type() do
        {:win32, _} ->
          {"cmd", win_cmd_args}

        {:unix, :darwin} ->
          {"open", [url]}

        {:unix, _} ->
          cond do
            System.find_executable("xdg-open") -> {"xdg-open", [url]}
            # When inside WSL
            System.find_executable("cmd.exe") -> {"cmd.exe", win_cmd_args}
            true -> nil
          end
      end

    case cmd_args do
      {cmd, args} -> System.cmd(cmd, args)
      nil -> Logger.warning("could not open the browser, no open command found in the system")
    end

    :ok
  end

  def configure_cli() do
    header("BVS CLI CONFIGURATION")
    message("Configuring Database...", :red)
    configure_database()
    message("Database configured!", :red)
    message("Configuring SFTP...", :red)
    configure_sftp()
    message("SFTP configured!", :red)
    footer()
    DoIt.Commfig.set("configured", true)
  end

  def configure_database() do
    {:ok, _filename} = create_db()
    {:ok, _} = BVS.Repo.start_link()
    :ok = migrate_db()
    :ok = seed_db()
  end

  def configure_sftp() do
    host = Prompt.text("Host")
    port = Prompt.text("Port") |> String.to_integer()
    dir = Prompt.text("Directory")
    user = Prompt.text("User")
    password = Prompt.password("Password")

    sftp = %{
      opts: %{
        host: host,
        port: port,
        user: user,
        password: password,
        sftp_vsn: 3
      },
      dir: dir
    }

    DoIt.Commfig.set("sftp", sftp)

    {:ok, sftp}
  end

  def create_db() do
    message("Creating database file...", :yellow)
    filename = Path.join(DoIt.Commfig.get_dir(), "bvs.db")

    if not File.exists?(filename) do
      Ecto.Adapters.SQLite3.storage_up(
        database: filename,
        pool_size: 2
      )
    end

    DoIt.Commfig.set("repo", %{"create" => "OK", "database" => filename})

    {:ok, filename}
  end

  def migrate_db() do
    message("Running migrations...", :yellow)

    for repo <- Application.fetch_env!(@app, :ecto_repos) do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end

    :ok
  end

  def seed_db() do
    message("Seeding database...", :yellow)

    @app
    |> :code.priv_dir()
    |> Path.join("repo/seeds.exs")
    |> Code.eval_file()

    :ok
  end

  defp header(text) do
    [
      :green,
      "================================================================================",
      "\n",
      text,
      "\n",
      "================================================================================"
    ]
    |> IO.ANSI.format()
    |> IO.puts()
  end

  defp footer() do
    [
      :green,
      "================================================================================"
    ]
    |> IO.ANSI.format()
    |> IO.puts()
  end

  defp message(text, color) do
    [
      color,
      text
    ]
    |> IO.ANSI.format()
    |> IO.puts()
  end
end
