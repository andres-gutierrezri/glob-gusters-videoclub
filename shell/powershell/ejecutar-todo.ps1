# =====================================================================================
# ejecutar-todo.ps1 — Ejecuta SQL, Python y Java en orden (Windows PowerShell)
# =====================================================================================
# Llama a ejecutar-sql.ps1, ejecutar-python.ps1 y ejecutar-java.ps1, y se detiene en el
# primer fallo de SQL o Java (si Python falla, avisa y continúa con Java). Acepta -SinPython y -SinJava para omitir un lenguaje.
#
# Uso (desde cualquier carpeta):
#     powershell -ExecutionPolicy Bypass -File shell\powershell\ejecutar-todo.ps1 [-SinPython] [-SinJava]
# =====================================================================================
param([switch]$SinPython, [switch]$SinJava)

. (Join-Path $PSScriptRoot 'lib.ps1')

& (Join-Path $PSScriptRoot 'ejecutar-sql.ps1')
if ($LASTEXITCODE -ne 0) { exit 1 }
$pyFallo = $false
if (-not $SinPython) {
    & (Join-Path $PSScriptRoot 'ejecutar-python.ps1')
    if ($LASTEXITCODE -ne 0) {
        $pyFallo = $true
        Aviso 'Los scripts de Python se detuvieron (entorno virtual, dependencias o ejecución). Se continúa con Java.'
    }
}
if (-not $SinJava) {
    & (Join-Path $PSScriptRoot 'ejecutar-java.ps1')
    if ($LASTEXITCODE -ne 0) { exit 1 }
}
if ($pyFallo) {
    Aviso 'Proyecto ejecutado con advertencias: SQL y Java terminaron bien, pero Python no se completó.'
} else {
    Ok 'Todo el proyecto se ejecutó correctamente.'
}
