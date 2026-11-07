# =====================================================================================
# ejecutar-python.ps1 — Ejecuta todos los scripts de py\ (Windows PowerShell)
# =====================================================================================
# Crea el entorno virtual .venv si no existe, actualiza pip, instala requirements.txt y ejecuta, en
# orden: conexion, ddl, dml, dql, vdl, dcl, tcl y conexion_mariabd. Requiere que la base
# ya exista (ejecutar-sql.ps1) y Python 3.9+.
#
# Si el paquete `mariadb` no se puede instalar (falta MariaDB Connector/C), se instala
# solo PyMySQL y se omite conexion_mariabd.py con un aviso; el resto funciona igual.
#
# Uso (desde cualquier carpeta):
#     powershell -ExecutionPolicy Bypass -File shell\powershell\ejecutar-python.ps1
# =====================================================================================
. (Join-Path $PSScriptRoot 'lib.ps1')
Set-Location $script:Raiz
Asegurar-Env

$venvPy = Join-Path $script:Raiz '.venv\Scripts\python.exe'
Info 'Verificando el entorno virtual .venv'
if (Test-Path $venvPy) {
    Ok 'El entorno virtual .venv ya existe.'
} else {
    Info 'El entorno virtual .venv no existe; creándolo'
    # Busca un Python 3.9+ real (ignora el alias vacío de la Tienda de Windows).
    $python = $null
    foreach ($c in @($env:PYTHON_BIN, 'py', 'python', 'python3')) {
        if (-not $c) { continue }
        if (-not (Get-Command $c -ErrorAction SilentlyContinue)) { continue }
        & $c -c 'import sys; sys.exit(0 if sys.version_info >= (3, 9) else 1)' 2>$null
        if ($LASTEXITCODE -eq 0) { $python = $c; break }
    }
    if (-not $python) { Falla 'No se encontró Python 3.9+. Instálalo (winget install Python.Python.3.13) o define PYTHON_BIN.'; exit 1 }
    Info 'Creando el entorno virtual .venv'
    & $python -m venv .venv
    if (($LASTEXITCODE -ne 0) -or -not (Test-Path $venvPy)) {
        Aviso 'No se pudo crear el entorno virtual .venv. Se detiene la ejecución.'
        Falla 'Sin entorno virtual no se instalan las dependencias ni se ejecutan los scripts de Python.'
        exit 1
    }
    Ok 'Entorno virtual .venv creado correctamente.'
}

Info 'Actualizando pip'
& $venvPy -m pip install --quiet --upgrade pip
if ($LASTEXITCODE -ne 0) { Aviso 'No se pudo actualizar pip (¿sin conexión a Internet?). Se continúa con la versión actual.' }

Info 'Instalando dependencias (requirements.txt)'
$conMariadb = $true
& $venvPy -m pip install --quiet -r requirements.txt
if ($LASTEXITCODE -ne 0) {
    Aviso "No se pudo instalar el paquete 'mariadb' (necesita MariaDB Connector/C >= 3.3.1). Se instala solo PyMySQL."
    & $venvPy -m pip install --quiet 'PyMySQL>=1.1'
    if ($LASTEXITCODE -ne 0) { Falla 'Falló la instalación de PyMySQL.'; exit 1 }
    $conMariadb = $false
}

Info 'Dependencias de Python instaladas en .venv (paquete y versión)'
& $venvPy -m pip list --format=columns
if ($LASTEXITCODE -ne 0) { Aviso 'No se pudo listar las dependencias instaladas.' }

# Fuerza UTF-8 en la salida de Python para que tildes y ñ se vean bien.
$env:PYTHONIOENCODING = 'utf-8'
foreach ($m in 'conexion', 'ddl', 'dml', 'dql', 'vdl', 'dcl', 'tcl', 'conexion_mariabd') {
    if ($m -eq 'conexion_mariabd' -and -not $conMariadb) {
        Aviso "Se omite py\conexion_mariabd.py (requiere el paquete 'mariadb')."
        continue
    }
    Info "py\$m.py"
    & $venvPy "py\$m.py"
    if ($LASTEXITCODE -ne 0) { Falla "Falló py\$m.py"; exit 1 }
}
Ok 'Python completado.'
exit 0
