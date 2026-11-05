# =====================================================================================
# ejecutar-java.ps1 — Compila y ejecuta todas las clases de java\ (Windows PowerShell)
# =====================================================================================
# Descarga el driver JDBC (MariaDB Connector/J 3.5.3) a java\lib\ si falta, compila con
# javac y ejecuta, en orden: Conexion, Ddl, Dml, Dql, Vdl, Dcl y Tcl. Requiere JDK 17+
# y que la base ya exista (ejecutar-sql.ps1). El separador del classpath en Windows es `;`.
#
# Uso (desde cualquier carpeta):
#     powershell -ExecutionPolicy Bypass -File shell\powershell\ejecutar-java.ps1
# =====================================================================================
. (Join-Path $PSScriptRoot 'lib.ps1')

$jar = 'mariadb-java-client-3.5.3.jar'
$url = "https://repo1.maven.org/maven2/org/mariadb/jdbc/mariadb-java-client/3.5.3/$jar"

if (-not ((Get-Command javac -ErrorAction SilentlyContinue) -and (Get-Command java -ErrorAction SilentlyContinue))) {
    Falla 'No se encontró el JDK (javac/java). Instálalo: winget install EclipseAdoptium.Temurin.17.JDK'
    exit 1
}

Asegurar-Env
Set-Location (Join-Path $script:Raiz 'java')

if (-not (Test-Path "lib\$jar")) {
    Info "Descargando $jar"
    New-Item -ItemType Directory -Force lib | Out-Null
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri $url -OutFile "lib\$jar" -UseBasicParsing
    } catch {
        Remove-Item "lib\$jar" -ErrorAction SilentlyContinue
        Falla "No se pudo descargar el driver desde $url"
        exit 1
    }
}

Info 'Compilando java\*.java'
$fuentes = (Get-ChildItem -Filter *.java).Name
& javac -encoding UTF-8 -d out @fuentes
if ($LASTEXITCODE -ne 0) { Falla 'Falló la compilación (¿JDK 17+?).'; exit 1 }

# Salida y entrada de Java en UTF-8 para que tildes y ñ se vean bien.
$env:JAVA_TOOL_OPTIONS = '-Dfile.encoding=UTF-8 -Dstdout.encoding=UTF-8 -Dstderr.encoding=UTF-8'
[Console]::OutputEncoding = [Text.Encoding]::UTF8
foreach ($c in 'Conexion', 'Ddl', 'Dml', 'Dql', 'Vdl', 'Dcl', 'Tcl') {
    Info "java $c"
    & java -cp 'out;lib/*' $c
    if ($LASTEXITCODE -ne 0) { Falla "Falló la clase $c"; exit 1 }
}
Ok 'Java completado.'
exit 0
