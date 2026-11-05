@echo off
rem ====================================================================================
rem ejecutar-java.cmd - Compila y ejecuta todas las clases de java\ (Windows CMD)
rem ====================================================================================
rem Descarga el driver JDBC (MariaDB Connector/J 3.5.3) a java\lib\ si falta, compila
rem con javac y ejecuta, en orden: Conexion, Ddl, Dml, Dql, Vdl, Dcl y Tcl. Requiere
rem JDK 17+ y que la base ya exista (ejecutar-sql.cmd). El separador del classpath en
rem Windows es ";".
rem
rem Uso (desde cualquier carpeta):
rem     shell\cmd\ejecutar-java.cmd
rem ====================================================================================
setlocal
call "%~dp0lib.cmd" || exit /b 1

set "JAR=mariadb-java-client-3.5.3.jar"
set "URL=https://repo1.maven.org/maven2/org/mariadb/jdbc/mariadb-java-client/3.5.3/%JAR%"

where javac >nul 2>&1 || goto :sinjdk
where java >nul 2>&1 || goto :sinjdk

cd /d "%RAIZ%"
if not exist ".env" (
    copy ".env.example" ".env" >nul
    echo [AVISO] Se creo .env a partir de .env.example. Si tu usuario tiene contrasena, edita GLOB_GUSTERS_PASSWORD.
)
cd /d "%RAIZ%\java"

if exist "lib\%JAR%" goto :compilar
echo ^>^>^> Descargando %JAR%
if not exist lib mkdir lib
curl -fsSL -o "lib\%JAR%" "%URL%"
if errorlevel 1 (
    del "lib\%JAR%" >nul 2>&1
    echo [ERROR] No se pudo descargar el driver desde %URL%
    echo [ERROR] Descargalo en el navegador y guardalo en java\lib\
    exit /b 1
)

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
