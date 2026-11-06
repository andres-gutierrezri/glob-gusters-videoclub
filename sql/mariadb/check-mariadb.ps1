# =====================================================================================
# check-mariadb.ps1 — Lanzador de check-mariadb.sql con la configuración del archivo .env
# =====================================================================================
# Un archivo SQL no puede leer el .env, así que este script lo hace por él: lee las
# variables de conexión, ejecuta el cliente `mariadb` con ellas y le pasa a
# check-mariadb.sql el nombre de la base de datos mediante la variable de sesión
# @glob_gusters_db. Es el equivalente en PowerShell de check-mariadb.sh.
#
# Variables que usa (las mismas de py\conexion.py y java\Conexion.java):
#   GLOB_GUSTERS_HOST       (por defecto localhost)
#   GLOB_GUSTERS_PORT       (por defecto 3306)
#   GLOB_GUSTERS_USER       (por defecto root)
#   GLOB_GUSTERS_PASSWORD   (por defecto vacía = sin contraseña)
#   GLOB_GUSTERS_DB         (por defecto glob_gusters)
# Prioridad: variable ya definida en el sistema > archivo .env > valor por defecto.
# Además, MARIADB_BIN permite indicar la ruta del cliente `mariadb` (opcional).
# La lectura del .env y la búsqueda del cliente las hace shell\powershell\lib.ps1.
#
# Uso (desde cualquier carpeta):
#     powershell -ExecutionPolicy Bypass -File sql\mariadb\check-mariadb.ps1
# =====================================================================================

. (Join-Path $PSScriptRoot '..\..\shell\powershell\lib.ps1')
Cargar-Conexion
Buscar-Cliente
Set-Location $script:Raiz

# Nombre de la base escapado para el literal SQL: se duplican las comillas simples y las barras.
$baseSql = $script:Base.Replace('\', '\').Replace("'", "''")

# Ejecuta el script con --force (para que las secciones que fallen por las limitaciones
# conocidas del entorno no detengan el reporte). --init-command define @glob_gusters_db
# nada más conectar. Se usa la orden `source` del cliente (no se canaliza texto por
# PowerShell), lo que evita los problemas de codificación de tildes y ñ.
& $script:Cliente -h $script:DbHost -P $script:Puerto -u $script:Usuario `
    --default-character-set=utf8mb4 --force `
    "--init-command=SET @glob_gusters_db = '$baseSql'" `
    -e 'source sql/mariadb/check-mariadb.sql'
exit $LASTEXITCODE
