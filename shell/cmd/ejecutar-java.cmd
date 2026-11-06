@echo off
rem ====================================================================================
rem ejecutar-java.cmd - Compila y ejecuta todas las clases de java\ (Windows CMD)
rem ====================================================================================
rem Primero actualiza el driver JDBC: consulta en Maven Central la ultima version 3.x
rem estable de MariaDB Connector/J y, si java\lib\ no la tiene, la descarga y borra las
rem anteriores (sin Internet usa el driver que haya; si no hay ninguno, baja la 3.5.3).
rem Solo se actualiza dentro de la serie 3.x: la 4.x exige TLS y no conecta con el
rem MariaDB de XAMPP sin configurarlo. Despues compila con javac y ejecuta, en orden:
rem Conexion, Ddl, Dml, Dql, Vdl, Dcl y Tcl. Requiere JDK 17+ y que la base ya exista
rem (ejecutar-sql.cmd). El separador del classpath en Windows es ";".
rem
rem Uso (desde cualquier carpeta):
rem     shell\cmd\ejecutar-java.cmd
rem ====================================================================================
setlocal
call "%~dp0lib.cmd" || exit /b 1

set "MAVEN=https://repo1.maven.org/maven2/org/mariadb/jdbc/mariadb-java-client"
rem Serie del driver que se mantiene actualizada y version que se baja si no hay Internet.
set "LINEA=3"
set "JAR_BASE=3.5.3"

where javac >nul 2>&1 || goto :sinjdk
where java >nul 2>&1 || goto :sinjdk

cd /d "%RAIZ%"
if not exist ".env" (
    copy ".env.example" ".env" >nul
    echo [AVISO] Se creo .env a partir de .env.example. Si tu usuario tiene contrasena, edita GLOB_GUSTERS_PASSWORD.
)
cd /d "%RAIZ%\java"

if not exist lib mkdir lib
echo ^>^>^> Actualizando el driver JDBC ^(ultima version %LINEA%.x de MariaDB Connector/J^)
rem Maven lista las versiones de menor a mayor: la ultima linea que coincide es la mas nueva.
set "ULTIMA="
for /f "tokens=3 delims=<>" %%v in ('curl -fsSL --max-time 20 "%MAVEN%/maven-metadata.xml" 2^>nul ^| findstr /r "<version>%LINEA%\.[0-9]*\.[0-9]*</version>"') do set "ULTIMA=%%v"
set "HAY_DRIVER="
if exist "lib\mariadb-java-client-*.jar" set "HAY_DRIVER=1"
if not defined ULTIMA (
    if defined HAY_DRIVER (
        echo [AVISO] No se pudo consultar la ultima version ^(sin conexion a Internet?^). Se usa el driver de java\lib.
        goto :compilar
    )
    set "ULTIMA=%JAR_BASE%"
)
set "JAR=mariadb-java-client-%ULTIMA%.jar"
if exist "lib\%JAR%" (
    echo [OK] Driver al dia: %JAR%
    goto :limpiar
)
echo ^>^>^> Descargando %JAR%
curl -fsSL --max-time 120 -o "lib\%JAR%.part" "%MAVEN%/%ULTIMA%/%JAR%"
if errorlevel 1 (
    del "lib\%JAR%.part" >nul 2>&1
    if defined HAY_DRIVER (
        echo [AVISO] No se pudo descargar %JAR%. Se usa el driver de java\lib.
        goto :compilar
    )
    echo [ERROR] No se pudo descargar el driver desde %MAVEN%/%ULTIMA%/%JAR%
    echo [ERROR] Descargalo en el navegador y guardalo en java\lib\
    exit /b 1
)
move /y "lib\%JAR%.part" "lib\%JAR%" >nul

:limpiar
rem Deja solo este driver: con varios en lib/* el classpath mezclaria versiones.
for %%f in ("lib\mariadb-java-client-*.jar") do if /i not "%%~nxf"=="%JAR%" del "%%f"

:compilar
echo ^>^>^> Compilando java\*.java
javac -encoding UTF-8 -d out *.java
if errorlevel 1 (
    echo [ERROR] Fallo la compilacion ^(JDK 17 o superior?^).
    exit /b 1
)

rem Salida de Java en UTF-8 para que tildes y enie se vean bien.
set "JAVA_TOOL_OPTIONS=-Dfile.encoding=UTF-8 -Dstdout.encoding=UTF-8 -Dstderr.encoding=UTF-8"
for %%c in (Conexion Ddl Dml Dql Vdl Dcl Tcl) do (
    echo ^>^>^> java %%c
    java -cp "out;lib/*" %%c
    if errorlevel 1 (
        echo [ERROR] Fallo la clase %%c
        exit /b 1
    )
)
echo [OK] Java completado.
exit /b 0

:sinjdk
echo [ERROR] No se encontro el JDK ^(javac/java^). Instala JDK 17 o superior: winget install EclipseAdoptium.Temurin.17.JDK
exit /b 1
