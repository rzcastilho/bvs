# BVS - Processador de Arquivos de Retorno Boa Vista Serviços

Aplicação Phoenix/Elixir para processamento automatizado de arquivos de retorno de bureaus de crédito. O sistema faz download de arquivos via SFTP, processa dados em formato de largura fixa e disponibiliza interface web para revisão de itens processados e erros.

## Características

- Download automático de arquivos via SFTP
- Parser de arquivos em formato binário de largura fixa (222 bytes por linha)
- Processamento em background com Oban
- Interface web com Phoenix LiveView para revisão de dados
- Rastreamento de status de arquivos (encontrado → baixado → processado/pendente)
- Modo CLI standalone ou servidor web

## Pré-requisitos

### Para Desenvolvimento
- Elixir 1.14 ou superior
- Erlang/OTP compatível
- Acesso a servidor SFTP com credenciais

### Para Uso em Produção
- **Opção 1**: Binário standalone (não requer Elixir instalado)
- **Opção 2**: Build a partir do código fonte (requer Elixir)

## Instalação

### Modo Desenvolvimento

```bash
# Clone o repositório
git clone <repository-url>
cd bvs

# Instalar dependências, criar banco de dados, executar migrations e compilar assets
mix setup

# Iniciar servidor Phoenix
mix phx.server
```

Acesse http://localhost:4000/return_files no navegador.

### Modo Produção - Binário Standalone

```bash
# Baixe o binário pré-compilado para sua plataforma
# (macOS x86_64, macOS ARM64, Linux x86_64, Linux ARM64, Windows x86_64)

# Ou compile do código fonte:
MIX_ENV=prod mix deps.get
MIX_ENV=prod mix assets.deploy
MIX_ENV=prod mix release

# Execute o binário
./bvs server
```

## Configuração

### Primeira Execução

Na primeira execução, o sistema solicitará as seguintes configurações:

**Configuração do Banco de Dados** (automática):
- O sistema cria automaticamente um arquivo SQLite
- Localização: `~/.bvs/bvs.db` (produção) ou raiz do projeto (dev)
- Migrations são executadas automaticamente
- Códigos de retorno e tipos de ocorrência são populados

**Configuração SFTP** (interativa):
```
Host: endereço do servidor SFTP
Port: porta do servidor SFTP (geralmente 22)
Directory: caminho do diretório remoto (ex: /home/user/negativacao/retorno)
User: nome de usuário SFTP
Password: senha SFTP (entrada mascarada)
```

A configuração é salva em:
- **Produção**: `~/.bvs/bvs.json`
- **Desenvolvimento**: `/tmp/bvs.json`

### Variáveis de Ambiente (Produção)

```bash
export PHX_HOST=localhost        # Host do servidor (padrão: localhost)
export PORT=4000                 # Porta HTTP (padrão: 4000)
export POOL_SIZE=5              # Tamanho do pool de conexões (padrão: 5)
```

### Reconfigurar o Sistema

Para reconfigurar, remova o arquivo de configuração e execute novamente:

```bash
rm ~/.bvs/bvs.json
./bvs server
```

## Uso

### Modo CLI (Produção)

```bash
./bvs server
```

Este comando:
1. Verifica/solicita configuração (primeira execução)
2. Inicializa o banco de dados
3. Inicia a aplicação Phoenix
4. Abre o navegador em http://localhost:4000/return_files
5. Agenda job para verificar novos arquivos no SFTP
6. Permanece em execução (pressione CTRL+C para sair)

### Modo Servidor Web (Desenvolvimento)

```bash
# Iniciar servidor
mix phx.server

# Ou com console IEx
iex -S mix phx.server
```

### Pipeline de Processamento de Arquivos

O sistema processa arquivos automaticamente seguindo este fluxo:

```
1. VerifyNewFiles (Job Oban)
   ↓
   Lista arquivos no diretório SFTP
   ↓
2. Cria registros ReturnFile para arquivos novos (status: :found)
   ↓
3. DownloadFile (Job Oban)
   ↓
   Baixa arquivo para /tmp (status: :downloaded)
   ↓
4. ProcessFile (Job Oban)
   ↓
   Parseia conteúdo do arquivo
   ↓
5. Extrai itens (nomes, endereços, ocorrências)
   ↓
6. Cria registros Item com códigos de retorno
   ↓
7. Atualiza status do ReturnFile:
   - :processed (todos os itens com código "00")
   - :pending (algum item com código de erro)
   - :error (falha no processamento)
```

### Status dos Arquivos

- **:found** - Arquivo detectado no SFTP
- **:downloaded** - Arquivo baixado para processamento
- **:processed** - Processado com sucesso (todos os itens OK)
- **:pending** - Processado mas contém itens com erro (requer revisão)
- **:error** - Falha no processamento

### Códigos de Retorno

- **"00"** - Operação bem sucedida
- **"16"-"99"** - Códigos de erro diversos (ver tabela completa na interface)
- **"5A"-"7P"** - Códigos de erro especiais

Arquivos com qualquer item que não seja "00" ficam com status **:pending** e devem ser revisados manualmente.

## Interface Web

Acesse http://localhost:4000 para utilizar a interface web.

### Seções Principais

**Return Files** (`/return_files`)
- Lista todos os arquivos processados
- Exibe status de cada arquivo
- Clique em um arquivo para ver detalhes e itens com erro
- Filtre por status

**Items** (`/items`)
- Visualize itens individuais parseados
- Veja códigos de retorno e detalhes
- Ordenados por arquivo e sequência

**Return Codes** (`/return_codes`)
- Gerenciar/visualizar definições de códigos de retorno
- Consultar significado de cada código

**Occurrence Types** (`/ocurrence_types`)
- Gerenciar tipos de ocorrência de crédito
- Códigos: CH (cheque), DP (duplicata), CP (crédito pessoal), etc.

### Revisão de Erros

1. Acesse `/return_files`
2. Identifique arquivos com status **pending** (contém erros)
3. Clique no arquivo para ver detalhes
4. Visualize apenas os itens com códigos de erro
5. Consulte o significado do código de retorno
6. Tome ação apropriada (corrigir dados de origem, etc.)

## Formato de Arquivo

### Requisitos

- **Formato**: Largura fixa binária
- **Tamanho da linha**: Exatamente 222 bytes
- **Codificação**: ASCII/Latin-1

### Tipos de Registro Suportados

**HEADER** (Cabeçalho do arquivo)
- Cliente (8 bytes)
- Data (6 bytes)
- Informante (55 bytes)
- Versão (2 bytes)
- Código de retorno (2 bytes)

**NOME** (Dados cadastrais da pessoa)
- Documentos: CPF, RG
- Nome completo (50 bytes)
- Data de nascimento
- Nome do cônjuge (40 bytes)
- Naturalidade e estado

**ENDEREÇO** (Dados de endereço)
- Endereço (50 bytes)
- Bairro (20 bytes)
- CEP (8 bytes)
- Cidade (20 bytes)
- UF (2 bytes)
- Telefone (20 bytes)

**OCORRÊNCIA** (Dados de negativação/crédito)
- Tipo de operação (inclusão/exclusão)
- Data da ocorrência
- Tipo de ocorrência (2 bytes)
- Contrato (22 bytes)
- Valores
- Datas de vencimento

**TRAILLER** (Fim do arquivo)
- Marcador de fim
- Data
- Código de retorno

### Tipos de Documento Suportados

CPF, RG, CNPJ, NIRE, CP, TE, CR, RE, CRM, OAB, CIE, IMA, IME, IMM, CNH, CF, CRC, PAS, RNE

## Desenvolvimento

### Comandos Úteis

```bash
# Executar testes
mix test

# Operações de banco de dados
mix ecto.create              # Criar banco de dados
mix ecto.migrate             # Executar migrations
mix ecto.rollback            # Reverter última migration
mix ecto.reset               # Dropar e recriar banco de dados
mix ecto.gen.migration name  # Gerar nova migration

# Assets
mix assets.build             # Compilar Tailwind CSS e esbuild
mix assets.deploy            # Compilar assets minificados para produção

# Popular banco de dados
mix run priv/repo/seeds.exs
```

### Estrutura do Projeto

```
lib/bvs/
├── commands/
│   └── server.ex              # Comando CLI principal
├── jobs/
│   ├── verify_new_files.ex    # Verificar novos arquivos no SFTP
│   ├── download_file.ex       # Baixar arquivo do SFTP
│   └── process_file.ex        # Processar conteúdo do arquivo
├── negativation/
│   ├── return_file.ex         # Schema de arquivo
│   ├── item.ex                # Schema de item parseado
│   ├── return_code.ex         # Schema de código de retorno
│   └── ocurrence_type.ex      # Schema de tipo de ocorrência
├── helpers.ex                 # Helpers de configuração
├── parser.ex                  # Parser de arquivo de largura fixa
├── ftp_server.ex              # GenServer wrapper para SFTP
└── application.ex             # Árvore de supervisão
```

## Deployment em Produção

### Build do Release

```bash
# Instalar dependências de produção
MIX_ENV=prod mix deps.get

# Compilar assets para produção
MIX_ENV=prod mix assets.deploy

# Criar release
MIX_ENV=prod mix release
```

### Plataformas Suportadas

O sistema usa Burrito para criar releases standalone multiplataforma:

- macOS x86_64
- macOS ARM64 (M1/M2)
- Linux x86_64
- Linux ARM64
- Windows x86_64

### Executar em Produção

```bash
# O binário inclui Erlang Runtime System (ERTS) embutido
# Não requer Elixir instalado no servidor

./bvs server
```

### Considerações de Produção

- **Banco de dados**: SQLite (portável, sem servidor externo necessário)
- **Porta padrão**: 4000 (configurável via variável PORT)
- **IPv6**: Suportado por padrão (bind em 0:0:0:0:0:0:0:0)
- **SSL/HTTPS**: Configurável (ver `config/runtime.exs`)
- **Logs**: Formato padrão do Logger do Elixir

## Troubleshooting

### Problema: Erro de conexão SFTP

```
Solução:
1. Verifique credenciais em ~/.bvs/bvs.json
2. Teste conexão SFTP manualmente:
   sftp -P <port> <user>@<host>
3. Verifique firewall e conectividade de rede
4. Reconfigure: rm ~/.bvs/bvs.json && ./bvs server
```

### Problema: Erro de formato de arquivo

```
Sintoma: Items não são criados, arquivo fica com status :error

Solução:
1. Verifique que o arquivo tem exatamente 222 bytes por linha
2. Confira codificação do arquivo (deve ser ASCII/Latin-1)
3. Valide estrutura dos registros (header, dados, trailer)
4. Revise logs para detalhes do erro de parsing
```

### Problema: Banco de dados corrompido

```
Solução:
# Modo desenvolvimento
rm dev.db*
mix ecto.reset

# Modo produção
rm ~/.bvs/bvs.db
./bvs server
# O sistema recriará o banco de dados automaticamente
```

### Problema: Jobs não estão sendo processados

```
Solução:
1. Verifique se o Oban está rodando (ver logs de inicialização)
2. Acesse /dev/dashboard em desenvolvimento para monitorar jobs
3. Verifique tabela oban_jobs no banco de dados
4. Reinicie a aplicação
```

### Logs e Debugging

```bash
# Modo desenvolvimento - logs aparecem no console
mix phx.server

# Modo produção - logs no stdout
./bvs server 2>&1 | tee bvs.log

# Aumentar nível de log (config/dev.exs ou config/prod.exs)
config :logger, level: :debug
```

## Licença

[Especifique a licença aqui]

## Suporte

Para reportar problemas ou solicitar funcionalidades, abra uma issue no repositório do projeto.

---

# BVS - Boa Vista Serviços Return File Processor

Phoenix/Elixir application for automated processing of credit bureau return files. The system downloads files via SFTP, processes fixed-width format data, and provides a web interface for reviewing processed items and errors.

## Features

- Automatic file download via SFTP
- Binary fixed-width format file parser (222 bytes per line)
- Background processing with Oban
- Phoenix LiveView web interface for data review
- File status tracking (found → downloaded → processed/pending)
- Standalone CLI mode or web server mode

## Prerequisites

### For Development
- Elixir 1.14 or higher
- Compatible Erlang/OTP
- SFTP server access with credentials

### For Production Use
- **Option 1**: Standalone binary (Elixir installation not required)
- **Option 2**: Build from source (Elixir required)

## Installation

### Development Mode

```bash
# Clone the repository
git clone <repository-url>
cd bvs

# Install dependencies, create database, run migrations, and compile assets
mix setup

# Start Phoenix server
mix phx.server
```

Access http://localhost:4000/return_files in your browser.

### Production Mode - Standalone Binary

```bash
# Download pre-compiled binary for your platform
# (macOS x86_64, macOS ARM64, Linux x86_64, Linux ARM64, Windows x86_64)

# Or compile from source:
MIX_ENV=prod mix deps.get
MIX_ENV=prod mix assets.deploy
MIX_ENV=prod mix release

# Run the binary
./bvs server
```

## Configuration

### First Run

On first run, the system will prompt for the following configuration:

**Database Configuration** (automatic):
- The system automatically creates a SQLite database file
- Location: `~/.bvs/bvs.db` (production) or project root (dev)
- Migrations run automatically
- Return codes and occurrence types are seeded

**SFTP Configuration** (interactive):
```
Host: SFTP server address
Port: SFTP server port (typically 22)
Directory: remote directory path (e.g., /home/user/negativacao/retorno)
User: SFTP username
Password: SFTP password (masked input)
```

Configuration is saved to:
- **Production**: `~/.bvs/bvs.json`
- **Development**: `/tmp/bvs.json`

### Environment Variables (Production)

```bash
export PHX_HOST=localhost        # Server host (default: localhost)
export PORT=4000                 # HTTP port (default: 4000)
export POOL_SIZE=5              # Connection pool size (default: 5)
```

### Reconfigure the System

To reconfigure, remove the configuration file and run again:

```bash
rm ~/.bvs/bvs.json
./bvs server
```

## Usage

### CLI Mode (Production)

```bash
./bvs server
```

This command:
1. Checks/prompts for configuration (first run)
2. Initializes the database
3. Starts the Phoenix application
4. Opens browser to http://localhost:4000/return_files
5. Schedules job to check for new files on SFTP
6. Runs indefinitely (press CTRL+C to exit)

### Web Server Mode (Development)

```bash
# Start server
mix phx.server

# Or with IEx console
iex -S mix phx.server
```

### File Processing Pipeline

The system processes files automatically following this flow:

```
1. VerifyNewFiles (Oban Job)
   ↓
   Lists files in SFTP directory
   ↓
2. Creates ReturnFile records for new files (status: :found)
   ↓
3. DownloadFile (Oban Job)
   ↓
   Downloads file to /tmp (status: :downloaded)
   ↓
4. ProcessFile (Oban Job)
   ↓
   Parses file content
   ↓
5. Extracts items (names, addresses, occurrences)
   ↓
6. Creates Item records with return codes
   ↓
7. Updates ReturnFile status:
   - :processed (all items with code "00")
   - :pending (any item with error code)
   - :error (processing failure)
```

### File Statuses

- **:found** - File detected on SFTP
- **:downloaded** - File downloaded for processing
- **:processed** - Successfully processed (all items OK)
- **:pending** - Processed but contains error items (requires review)
- **:error** - Processing failed

### Return Codes

- **"00"** - Successful operation
- **"16"-"99"** - Various error codes (see complete table in interface)
- **"5A"-"7P"** - Special error codes

Files with any item that is not "00" will have **:pending** status and must be reviewed manually.

## Web Interface

Access http://localhost:4000 to use the web interface.

### Main Sections

**Return Files** (`/return_files`)
- Lists all processed files
- Shows status of each file
- Click on a file to see details and error items
- Filter by status

**Items** (`/items`)
- View individual parsed items
- See return codes and details
- Ordered by file and sequence

**Return Codes** (`/return_codes`)
- Manage/view return code definitions
- Look up meaning of each code

**Occurrence Types** (`/ocurrence_types`)
- Manage credit occurrence types
- Codes: CH (check), DP (invoice), CP (personal credit), etc.

### Error Review

1. Access `/return_files`
2. Identify files with **pending** status (contains errors)
3. Click on file to see details
4. View only items with error codes
5. Look up return code meaning
6. Take appropriate action (fix source data, etc.)

## File Format

### Requirements

- **Format**: Binary fixed-width
- **Line size**: Exactly 222 bytes
- **Encoding**: ASCII/Latin-1

### Supported Record Types

**HEADER** (File header)
- Client (8 bytes)
- Date (6 bytes)
- Informant (55 bytes)
- Version (2 bytes)
- Return code (2 bytes)

**NAME** (Person registration data)
- Documents: CPF, RG
- Full name (50 bytes)
- Birth date
- Spouse name (40 bytes)
- Place of birth and state

**ADDRESS** (Address data)
- Address (50 bytes)
- Neighborhood (20 bytes)
- ZIP code (8 bytes)
- City (20 bytes)
- State (2 bytes)
- Phone (20 bytes)

**OCCURRENCE** (Credit/negative data)
- Operation type (inclusion/exclusion)
- Occurrence date
- Occurrence type (2 bytes)
- Contract (22 bytes)
- Values
- Due dates

**TRAILER** (File end)
- End marker
- Date
- Return code

### Supported Document Types

CPF, RG, CNPJ, NIRE, CP, TE, CR, RE, CRM, OAB, CIE, IMA, IME, IMM, CNH, CF, CRC, PAS, RNE

## Development

### Useful Commands

```bash
# Run tests
mix test

# Database operations
mix ecto.create              # Create database
mix ecto.migrate             # Run migrations
mix ecto.rollback            # Rollback last migration
mix ecto.reset               # Drop and recreate database
mix ecto.gen.migration name  # Generate new migration

# Assets
mix assets.build             # Compile Tailwind CSS and esbuild
mix assets.deploy            # Compile minified assets for production

# Seed database
mix run priv/repo/seeds.exs
```

### Project Structure

```
lib/bvs/
├── commands/
│   └── server.ex              # Main CLI command
├── jobs/
│   ├── verify_new_files.ex    # Check for new files on SFTP
│   ├── download_file.ex       # Download file from SFTP
│   └── process_file.ex        # Process file content
├── negativation/
│   ├── return_file.ex         # File schema
│   ├── item.ex                # Parsed item schema
│   ├── return_code.ex         # Return code schema
│   └── ocurrence_type.ex      # Occurrence type schema
├── helpers.ex                 # Configuration helpers
├── parser.ex                  # Fixed-width file parser
├── ftp_server.ex              # SFTP GenServer wrapper
└── application.ex             # Supervision tree
```

## Production Deployment

### Build Release

```bash
# Install production dependencies
MIX_ENV=prod mix deps.get

# Compile assets for production
MIX_ENV=prod mix assets.deploy

# Create release
MIX_ENV=prod mix release
```

### Supported Platforms

The system uses Burrito to create cross-platform standalone releases:

- macOS x86_64
- macOS ARM64 (M1/M2)
- Linux x86_64
- Linux ARM64
- Windows x86_64

### Run in Production

```bash
# The binary includes embedded Erlang Runtime System (ERTS)
# Does not require Elixir installed on server

./bvs server
```

### Production Considerations

- **Database**: SQLite (portable, no external server needed)
- **Default port**: 4000 (configurable via PORT variable)
- **IPv6**: Supported by default (bind to 0:0:0:0:0:0:0:0)
- **SSL/HTTPS**: Configurable (see `config/runtime.exs`)
- **Logs**: Standard Elixir Logger format

## Troubleshooting

### Problem: SFTP connection error

```
Solution:
1. Check credentials in ~/.bvs/bvs.json
2. Test SFTP connection manually:
   sftp -P <port> <user>@<host>
3. Check firewall and network connectivity
4. Reconfigure: rm ~/.bvs/bvs.json && ./bvs server
```

### Problem: File format error

```
Symptom: Items are not created, file has :error status

Solution:
1. Verify file has exactly 222 bytes per line
2. Check file encoding (must be ASCII/Latin-1)
3. Validate record structure (header, data, trailer)
4. Review logs for parsing error details
```

### Problem: Corrupted database

```
Solution:
# Development mode
rm dev.db*
mix ecto.reset

# Production mode
rm ~/.bvs/bvs.db
./bvs server
# The system will automatically recreate the database
```

### Problem: Jobs are not being processed

```
Solution:
1. Check if Oban is running (see startup logs)
2. Access /dev/dashboard in development to monitor jobs
3. Check oban_jobs table in database
4. Restart the application
```

### Logs and Debugging

```bash
# Development mode - logs appear in console
mix phx.server

# Production mode - logs to stdout
./bvs server 2>&1 | tee bvs.log

# Increase log level (config/dev.exs or config/prod.exs)
config :logger, level: :debug
```

## License

[Specify license here]

## Support

To report issues or request features, open an issue in the project repository.
