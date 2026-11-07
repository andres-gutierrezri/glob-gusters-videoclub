# =====================================================================================
# ejecutar-java.ps1 — Compila y ejecuta todas las clases de java\ (Windows PowerShell)
# =====================================================================================
# Primero actualiza el driver JDBC: consulta en Maven Central la última versión 3.x
# estable de MariaDB Connector/J y, si java\lib\ no la tiene, la descarga y borra las
# anteriores (sin Internet usa el driver que haya; si no hay ninguno, baja la 3.5.3).
# Solo se actualiza dentro de la serie 3.x: la 4.x exige TLS y no conecta con el MariaDB
# de XAMPP sin configurarlo. Después compila con javac y ejecuta, en orden: Conexion,
# Ddl, Dml, Dql, Vdl, Dcl y Tcl. Requiere JDK 17+ y que la base ya exista
# (ejecutar-sql.ps1). El separador del classpath en Windows es `;`.
#
# Uso (desde cualquier carpeta):
#     powershell -ExecutionPolicy Bypass -File shell\powershell\ejecutar-java.ps1
# =====================================================================================
. (Join-Path $PSScriptRoot 'lib.ps1')

$maven = 'https://repo1.maven.org/maven2/org/mariadb/jdbc/mariadb-java-client'
$linea = 3            # serie del driver que se mantiene actualizada
$jarBase = '3.5.3'    # versión que se baja si no hay Internet y aún no hay driver

if (-not ((Get-Command javac -ErrorAction SilentlyContinue) -and (Get-Command java -ErrorAction SilentlyContinue))) {
    Falla 'No se encontró el JDK (javac/java). Instálalo: winget install EclipseAdoptium.Temurin.17.JDK'
    exit 1
}

Asegurar-Env
Set-Location (Join-Path $script:Raiz 'java')

New-Item -ItemType Directory -Force lib | Out-Null
Info "Actualizando el driver JDBC (última versión $linea.x de MariaDB Connector/J)"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$ultima = $null
try {
    $meta = [xml](Invoke-WebRequest -Uri "$maven/maven-metadata.xml" -UseBasicParsing -TimeoutSec 20).Content
    $ultima = $meta.metadata.versioning.versions.version |
        Where-Object { $_ -match "^$linea\.\d+\.\d+$" } |
        Sort-Object { [version]$_ } | Select-Object -Last 1
} catch { }
$existentes = @(Get-ChildItem 'lib\mariadb-java-client-*.jar' -ErrorAction SilentlyContinue)
if (-not $ultima) {
    if ($existentes.Count -gt 0) {
        Aviso 'No se pudo consultar la última versión (¿sin conexión a Internet?). Se usa el driver de java\lib.'
    } else {
        $ultima = $jarBase
    }
}
if ($ultima) {
    $jar = "mariadb-java-client-$ultima.jar"
    if (Test-Path "lib\$jar") {
        Ok "Driver al día: $jar"
        Get-ChildItem 'lib\mariadb-java-client-*.jar' | Where-Object { $_.Name -ne $jar } | Remove-Item -Force
    } else {
        Info "Descargando $jar"
        try {
            Invoke-WebRequest -Uri "$maven/$ultima/$jar" -OutFile "lib\$jar.part" -UseBasicParsing -TimeoutSec 120
            Move-Item -Force "lib\$jar.part" "lib\$jar"
            Ok "Driver JDBC descargado correctamente: $jar"
            # Deja solo este driver: con varios en lib/* el classpath mezclaría versiones.
            Get-ChildItem 'lib\mariadb-java-client-*.jar' | Where-Object { $_.Name -ne $jar } | Remove-Item -Force
        } catch {
            Remove-Item "lib\$jar.part" -ErrorAction SilentlyContinue
            if ($existentes.Count -gt 0) {
                Aviso "No se pudo descargar $jar. Se usa el driver de java\lib."
            } else {
                Falla "No se pudo descargar el driver desde $maven/$ultima/$jar. Se detiene la ejecución de los scripts de Java."
                exit 1
            }
        }
    }
}

# Verificación final: sin el driver JDBC no se compila ni se ejecuta nada de Java.
$jarOk = Get-ChildItem 'lib\mariadb-java-client-*.jar' -ErrorAction SilentlyContinue | Where-Object { $_.Length -gt 0 } | Select-Object -First 1
if (-not $jarOk) {
    Falla 'No se encontró un driver JDBC válido en java\lib. Se detiene la ejecución de los scripts de Java.'
    exit 1
}
Ok "Driver JDBC verificado: $($jarOk.Name)"

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
