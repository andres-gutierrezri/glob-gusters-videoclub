# =====================================================================================
# configurar-utf8.ps1 — Configura PowerShell para imprimir tildes, ñ y símbolos (UTF-8)
# =====================================================================================
# Para que el cambio quede en la sesión actual hay que cargarlo "con punto":
#     . .\shell\powershell\configurar-utf8.ps1
# Si se ejecuta normalmente (.\configurar-utf8.ps1) solo afecta a ese proceso y se pierde.
#
# Parámetro:
#   -Persistente   Además agrega la configuración al perfil ($PROFILE) para que valga en
#                  todas las sesiones nuevas de PowerShell (es idempotente).
#
# Configura: página de códigos 65001, [Console]::OutputEncoding/InputEncoding, $OutputEncoding
# (lo que se envía a programas externos) y PYTHONIOENCODING. Funciona en Windows PowerShell 5.1 y PowerShell 7.
# Nota: la consola debe usar una fuente TrueType (Consolas, Cascadia Mono, Lucida Console).
# =====================================================================================
param([switch]$Persistente)

$marca = '# >>> glob-gusters utf8 >>>'
$fin   = '# <<< glob-gusters utf8 <<<'
$bloque = @'
# >>> glob-gusters utf8 >>>
try {
    chcp 65001 | Out-Null
    $utf8 = New-Object System.Text.UTF8Encoding $false
    [Console]::OutputEncoding = $utf8
    [Console]::InputEncoding  = $utf8
    $OutputEncoding = $utf8
} catch { }
$env:PYTHONIOENCODING = 'utf-8'
# <<< glob-gusters utf8 <<<
'@

# Aplica el bloque a esta sesión
Invoke-Expression $bloque

if ($Persistente) {
    $perfil = $PROFILE.CurrentUserCurrentHost
    $dir = Split-Path $perfil
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force $dir | Out-Null }
    $actual = if (Test-Path $perfil) { Get-Content -Raw -Path $perfil } else { '' }
    if ($actual -and $actual.Contains($marca)) {
        Write-Host "[OK] El perfil ya tenía la configuración UTF-8: $perfil" -ForegroundColor Green
    } else {
        Add-Content -Path $perfil -Value ("`r`n" + $bloque) -Encoding UTF8
        Write-Host "[OK] Configuración UTF-8 agregada al perfil: $perfil" -ForegroundColor Green
    }
}

if ($MyInvocation.InvocationName -ne '.') {
    Write-Host '[AVISO] Se ejecutó sin punto: el cambio solo valió para este proceso.' -ForegroundColor Yellow
    Write-Host '        Use:  . .\shell\powershell\configurar-utf8.ps1' -ForegroundColor Yellow
}

Write-Host "[OK] Consola en UTF-8 (página de códigos $([Console]::OutputEncoding.CodePage)). Prueba: áéíóú ñ Ñ ü ¿¡ €" -ForegroundColor Green
