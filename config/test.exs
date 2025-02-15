import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :bvs, BVS.Repo,
  database: Path.expand("../bvs_test.db", __DIR__),
  pool_size: 5,
  pool: Ecto.Adapters.SQL.Sandbox

config :bvs, Oban,
  testing: :inline,
  notifier: Oban.Notifiers.PG

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :bvs, BVSWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "Wmvug19JKHEFPhtdMJUnOT3lIVBwx7Kc0ZztzPdWCqEEbInwWabMvynUPrs+lmAm",
  server: false

# In test we don't send emails.
config :bvs, BVS.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :phoenix_live_view,
  # Enable helpful, but potentially expensive runtime checks
  enable_expensive_runtime_checks: true

config :bvs, :sftp,
  host: "localhost",
  port: 9022,
  user: "user",
  password: "pass",
  sftp_vsn: 3
