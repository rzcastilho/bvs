# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

BVS is a Phoenix/Elixir application for processing credit bureau return files (Boa Vista Serviços). It downloads files via SFTP, parses fixed-width format data (names, addresses, credit occurrences), and provides a web UI for reviewing processed items and errors.

The application can run as:
- **Web server** (Phoenix): `mix phx.server` - browse to http://localhost:4000
- **CLI application** (Burrito): Built with `MIX_ENV=prod mix release` - runs as standalone binary

## Development Commands

### Setup
```bash
mix setup                    # Install deps, create DB, run migrations, setup assets
mix ecto.reset              # Drop and recreate database
```

### Running
```bash
mix phx.server              # Start Phoenix server (web UI at localhost:4000)
iex -S mix phx.server       # Start with IEx shell
mix run priv/repo/seeds.exs # Populate return_codes and ocurrence_types tables
```

### Testing
```bash
mix test                    # Run all tests (creates test DB automatically)
```

### Assets
```bash
mix assets.build            # Build Tailwind CSS and esbuild assets
mix assets.deploy           # Minified assets for production
```

### Database
```bash
mix ecto.create             # Create database
mix ecto.migrate            # Run migrations
mix ecto.gen.migration name # Generate new migration
```

### Production Build
```bash
MIX_ENV=prod mix deps.get
MIX_ENV=prod mix assets.deploy
MIX_ENV=prod mix release
```

## Architecture

### Core Domain: Negativation Context

The `BVS.Negativation` context (`lib/bvs/negativation.ex`) manages credit bureau data:

**Schemas:**
- `ReturnFile` - Represents downloaded files with status tracking (:found, :downloaded, :processed, :reviewed, :pending, :error)
- `Item` - Individual parsed records (type: :name, :address, :ocurrence) with document info and return codes
- `ReturnCode` - Processing result codes ("00" = success, others = errors)
- `OcurrenceType` - Credit occurrence categories (CH=cheque, DP=duplicata, CP=crédito pessoal, etc.)

**Key relationships:**
- ReturnFile has_many Items
- Item belongs_to ReturnFile and ReturnCode

### Background Job Processing (Oban)

Three workers in `lib/bvs/jobs/`:

1. `VerifyNewFiles` - Lists SFTP directory, creates ReturnFile records for new files, enqueues downloads
2. `DownloadFile` - Downloads file from SFTP, updates ReturnFile status to :downloaded
3. `ProcessFile` - Parses file content, creates Items, updates ReturnFile status to :processed

Jobs are configured in `config/runtime.exs` for production (Oban.Engines.Lite with SQLite).

### File Parser

`BVS.Parser` (`lib/bvs/parser.ex`) handles fixed-width format parsing:
- Pattern matches binary data with specific byte sizes
- Extracts header, name, address, occurrence, and trailer records
- Sanitizes data (trims whitespace, normalizes documents)
- Maps return codes from string codes to database IDs

Important: Parser expects exact 222-byte lines with specific field positions.

### SFTP Integration

`BVS.FTPServer` (`lib/bvs/ftp_server.ex`) is a GenServer wrapping SFTPClient:
- Maintains persistent SFTP connection
- Operations: `list_dir/1`, `download_file/3`
- Configuration stored in `DoIt.Commfig` (for CLI) or `Application.get_env(:bvs, :sftp)`

### Web Interface (Phoenix LiveView)

Four main LiveView modules in `lib/bvs_web/live/`:
- `ReturnCodeLive` - Manage return code definitions
- `OcurrenceTypeLive` - Manage occurrence type definitions
- `ReturnFileLive` - View files and their processing status, display errors
- `ItemLive` - View individual parsed items

All use standard LiveView patterns (Index/Show/FormComponent).

### Application Supervision Tree

Defined in `lib/bvs/application.ex`:
1. Telemetry
2. Repo (SQLite via ecto_sqlite3)
3. FTPServer GenServer
4. Oban
5. PubSub
6. Finch (for email)
7. Endpoint

### CLI Mode

The `do_it` library provides CLI commands:
- Main: `BVS` module with `BVS.Commands.Server`
- CLI runs `BVS.Application.start/2`, opens browser to return_files, enqueues VerifyNewFiles job
- Configuration via `DoIt.Commfig` (JSON file at `~/.bvs/bvs.json` in prod, `/tmp/bvs.json` in dev)

## Database

Uses SQLite (ecto_sqlite3) for portability with the standalone binary release.

**Important tables:**
- `return_files` - File tracking with status enum
- `items` - Parsed records with JSONB details column for flexible storage
- `return_codes` - Static reference data (populated via seeds)
- `ocurrence_types` - Static reference data (populated via seeds)
- `oban_jobs` - Job queue
- `oban_peers` - Oban coordination (Lite engine)

## Configuration

- `config/config.exs` - Base config (Ecto, Phoenix, asset pipeline)
- `config/dev.exs` - Development SFTP config, dev routes, live reload
- `config/test.exs` - Test database config
- `config/runtime.exs` - Production runtime config (reads env vars, configures Oban)

Production requires:
- `PHX_HOST` (default: localhost)
- `PORT` (default: 4000)
- `POOL_SIZE` (default: 5)

## Release Configuration

Uses Burrito for cross-platform standalone releases with embedded ERTS.

Targets in `mix.exs`:
- macos (x86_64)
- macos_m1 (aarch64)
- linux (x86_64)
- linux_aarch64
- windows (x86_64)

## Common Patterns

### Adding a new background job
1. Create module in `lib/bvs/jobs/` using `use Oban.Worker`
2. Implement `perform/1` with pattern match on job args
3. Enqueue with `MyJob.new(%{args}) |> Oban.insert!()`

### Adding a new LiveView resource
Use Phoenix generators:
```bash
mix phx.gen.live Negativation EntityName entity_names field1:type field2:type
```
Then update router and run migrations.

### Modifying the parser
When changing file format in `BVS.Parser`:
- Update binary pattern match clauses with exact byte sizes
- Ensure total line length = 222 bytes
- Update `to_insertion/1` to map parsed data to Item schema
- Test with sample return files
