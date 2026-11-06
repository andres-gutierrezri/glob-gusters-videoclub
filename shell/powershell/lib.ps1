# =====================================================================================
# lib.ps1 — Funciones comunes de los lanzadores de PowerShell (Windows)
# =====================================================================================
# No se ejecuta directamente: los demás scripts de esta carpeta lo cargan con `. .\lib.ps1`.
#
# Define:
#   $Raiz, $SqlScripts          Raíz del proyecto y los 8 scripts SQL en orden.
#   (al cargarse)               Deja la consola, $OutputEncoding y PYTHONIOENCODING en UTF-8 (tildes y ñ).
#   Info / Ok / Aviso / Falla   Mensajes con color.
#   Cargar-Conexion             Resuelve host, puerto, usuario, clave y base (sistema > .env > defecto).
#   Buscar-Cliente              Encuentra mariadb.exe (o mysql.exe).
#   Asegurar-Env                Crea .env desde .env.example si todavía no existe.
#
# Variables de conexión (las mismas que usan py\conexion.py y java\Conexion.java):
#   GLOB_GUSTERS_HOST, GLOB_GUSTERS_PORT, GLOB_GUSTERS_USER, GLOB_GUSTERS_PASSWORD,
#   GLOB_GUSTERS_DB. Además, MARIADB_BIN indica la ruta del cliente (opcional).
# =====================================================================================

# Salida en UTF-8 (sin BOM) para que las tildes y la ñ se impriman bien: la consola, lo que
# PowerShell lee de los programas externos (mariadb, python, java) y la de Python.
# Windows PowerShell 5.1 usa por defecto la página de códigos OEM (850/437) y rompe los acentos.
try {
    $utf8 = New-Object System.Text.UTF8Encoding $false
    [Console]::OutputEncoding = $utf8
    $OutputEncoding = $utf8
} catch { }   # sin consola asociada (salida redirigida en algunos entornos): se ignora
$env:PYTHONIOENCODING = 'utf-8'

$script:Raiz = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$script:EnvArchivo = Join-Path $script:Raiz '.env'

$script:SqlScripts = @(
    'sql/mariadb/glob_gusters.sql',
    'sql/mariadb/glob_gusters_insert.sql',
    'sql/mariadb/commands/01_DDL.sql',
    'sql/mariadb/commands/02_DML.sql',
    'sql/mariadb/commands/03_DQL.sql',
    'sql/mariadb/commands/04_VDL.sql',
    'sql/mariadb/commands/05_DCL.sql',
    'sql/mariadb/commands/06_TCL.sql'
)

function Info($m)   { Write-Host ">>> $m" -ForegroundColor Cyan }
function Ok($m)     { Write-Host "[OK] $m" -ForegroundColor Green }
function Aviso($m)  { Write-Host "[AVISO] $m" -ForegroundColor Yellow }
function Falla($m)  { Write-Host "[ERROR] $m" -ForegroundColor Red }

# Valor de CLAVE en el .env o, si no está o está vacío, el valor por defecto.
# Solo lee texto: no ejecuta nada de lo que haya dentro del archivo.
function Leer-Env($clave, $defecto) {
    $valor = ''
    if (Test-Path $script:EnvArchivo) {
        $patron = "^\s*(export\s+)?$clave\s*=\s*(.*?)\s*$"
        $lineas = Get-Content -Path $script:EnvArchivo -Encoding UTF8 | Where-Object { $_ -match $patron }
        if ($lineas) {
            $null = ($lineas | Select-Object -Last 1) -match $patron
            $valor = $Matches[2].Trim('"', "'")
        }
    }
    if ($valor) { return $valor } else { return $defecto }
}

function Cargar-Conexion {
    $e = [Environment]
    $script:DbHost = $e::GetEnvironmentVariable('GLOB_GUSTERS_HOST'); if (-not $script:DbHost) { $script:DbHost = Leer-Env 'GLOB_GUSTERS_HOST' 'localhost' }
    $script:Puerto = $e::GetEnvironmentVariable('GLOB_GUSTERS_PORT'); if (-not $script:Puerto) { $script:Puerto = Leer-Env 'GLOB_GUSTERS_PORT' '3306' }
    $script:Usuario = $e::GetEnvironmentVariable('GLOB_GUSTERS_USER'); if (-not $script:Usuario) { $script:Usuario = Leer-Env 'GLOB_GUSTERS_USER' 'root' }
    $script:Base = $e::GetEnvironmentVariable('GLOB_GUSTERS_DB'); if (-not $script:Base) { $script:Base = Leer-Env 'GLOB_GUSTERS_DB' 'glob_gusters' }
    $clave = $e::GetEnvironmentVariable('GLOB_GUSTERS_PASSWORD'); if ($null -eq $clave) { $clave = Leer-Env 'GLOB_GUSTERS_PASSWORD' '' }
    # Con "localhost" el cliente podría usar otro canal local; se fuerza TCP con 127.0.0.1.
    if ($script:DbHost -eq 'localhost') { $script:DbHost = '127.0.0.1' }
    # El cliente lee la contraseña de MYSQL_PWD: así no aparece en la lista de procesos.
    if ($clave) { $env:MYSQL_PWD = $clave }
}

function Buscar-Cliente {
    $c = $env:MARIADB_BIN
    if (-not $c) {
        $candidatos = @('mariadb', 'mysql', 'C:\xampp\mysql\bin\mariadb.exe', 'C:\xampp\mysql\bin\mysql.exe')
        foreach ($x in $candidatos) {
            if (Get-Command $x -ErrorAction SilentlyContinue) { $c = $x; break }
        }
    }
    if (-not $c) {
        Falla "No se encontró el cliente 'mariadb'. Agrega C:\xampp\mysql\bin al PATH o define MARIADB_BIN."
        Falla '  Ejemplo: $env:MARIADB_BIN = "C:\xampp\mysql\bin\mariadb.exe"'
        exit 1
    }
    $script:Cliente = $c
}

function Asegurar-Env {
    if (-not (Test-Path $script:EnvArchivo)) {
        Copy-Item (Join-Path $script:Raiz '.env.example') $script:EnvArchivo
        Aviso 'Se creó .env a partir de .env.example. Si tu usuario tiene contraseña, edita GLOB_GUSTERS_PASSWORD.'
    }
}
