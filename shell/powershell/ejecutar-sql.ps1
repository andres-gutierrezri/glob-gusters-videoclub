# =====================================================================================
# ejecutar-sql.ps1 — Ejecuta todos los scripts SQL de MariaDB (Windows PowerShell)
# =====================================================================================
# Orden: glob_gusters.sql -> glob_gusters_insert.sql -> commands\01_DDL ... 06_TCL,
# y después las pruebas de integridad y el diagnóstico del servidor. Los scripts son
# repetibles. Se detiene en el primer error de los 8 scripts; las pruebas y el
# diagnóstico se ejecutan con --force porque es normal que impriman algunos ERROR
# esperados (ver README).
#
# Se usa la orden `source` del propio cliente (no se canaliza texto por PowerShell), lo
# que evita los problemas de codificación de tildes y ñ.
#
# Uso (desde cualquier carpeta):
#     powershell -ExecutionPolicy Bypass -File shell\powershell\ejecutar-sql.ps1 [-SinPruebas] [-SinDiagnostico]
#
# Si el cliente no está en el PATH:  $env:MARIADB_BIN = "C:\xampp\mysql\bin\mariadb.exe"
# Si root tiene contraseña: defínela en .env (GLOB_GUSTERS_PASSWORD) o en el entorno.
# =====================================================================================
param([switch]$SinPruebas, [switch]$SinDiagnostico)

. (Join-Path $PSScriptRoot 'lib.ps1')
Cargar-Conexion
Buscar-Cliente
Set-Location $script:Raiz
Info "Servidor: $($script:Usuario)@$($script:DbHost):$($script:Puerto)  (cliente: $($script:Cliente))"

$conexion = @('-h', $script:DbHost, '-P', $script:Puerto, '-u', $script:Usuario, '--default-character-set=utf8mb4')

foreach ($f in $script:SqlScripts) {
    Info $f
    & $script:Cliente @conexion -e "source $f"
    if ($LASTEXITCODE -ne 0) {
        Falla "Falló $f. ¿Está el servidor en marcha y son correctas las credenciales?"
        exit 1
    }
}
Ok "Los $($script:SqlScripts.Count) scripts SQL terminaron sin errores."

if (-not $SinPruebas) {
    Info "tests/mariadb/glob_gusters_test.sql (se esperan 3 líneas ERROR y 'PROYECTO OK')"
    & $script:Cliente @conexion --force $script:Base -e 'source tests/mariadb/glob_gusters_test.sql'
    if ($LASTEXITCODE -ne 0) { Falla 'Fallaron las pruebas.'; exit 1 }
}

if (-not $SinDiagnostico) {
    Info 'sql/mariadb/check-mariadb.sql (diagnóstico del servidor)'
    $baseSql = $script:Base.Replace('\', '\\').Replace("'", "''")
    & $script:Cliente @conexion --force "--init-command=SET @glob_gusters_db = '$baseSql'" -e 'source sql/mariadb/check-mariadb.sql'
    if ($LASTEXITCODE -ne 0) { Aviso 'El diagnóstico terminó con avisos (ver mensajes arriba).' }
}
Ok 'SQL completado.'
exit 0
