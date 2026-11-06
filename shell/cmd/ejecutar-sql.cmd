@echo off
rem ====================================================================================
rem ejecutar-sql.cmd - Ejecuta todos los scripts SQL de MariaDB (Windows CMD)
rem ====================================================================================
rem Primero comprueba las versiones: muestra la del cliente y la del servidor y avisa si el
rem servidor es anterior a MariaDB 10.2.1 (no instala nada ni pide permisos de administrador).
rem
rem Orden: glob_gusters.sql, glob_gusters_insert.sql, commands\01_DDL ... 06_TCL, y despues
rem las pruebas de integridad y el diagnostico del servidor. Los scripts son repetibles.
rem Se detiene en el primer error de los 8 scripts; las pruebas y el diagnostico se
rem ejecutan con --force porque es normal que impriman algunos ERROR esperados (ver README).
rem
rem Uso (desde cualquier carpeta):
rem     shell\cmd\ejecutar-sql.cmd [--sin-pruebas] [--sin-diagnostico]
rem
rem Si el cliente no esta en el PATH:  set MARIADB_BIN=C:\xampp\mysql\bin\mariadb.exe
rem Si root tiene contrasena: definela en .env (GLOB_GUSTERS_PASSWORD) o en el entorno.
rem ====================================================================================
setlocal
set "CHECK_CLIENTE=1"
call "%~dp0lib.cmd" || exit /b 1
cd /d "%RAIZ%"

set "PRUEBAS=1"
set "DIAGNOSTICO=1"
:args
if "%~1"=="" goto :inicio
if "%~1"=="--sin-pruebas" set "PRUEBAS=0"
if "%~1"=="--sin-diagnostico" set "DIAGNOSTICO=0"
shift
goto :args

:inicio
echo ^>^>^> Servidor: %DB_USER%@%DB_HOST%:%DB_PORT%  (cliente: %CLIENTE%)

echo ^>^>^> Comprobando las versiones del cliente y del servidor
rem Las versiones se leen a un archivo temporal para no depender de espacios en la ruta del cliente.
set "TMP_VER=%TEMP%\glob_gusters_version.txt"
"%CLIENTE%" --version > "%TMP_VER%" 2>nul
set "VER_CLIENTE="
set /p VER_CLIENTE=<"%TMP_VER%"
echo ^>^>^> Cliente: %VER_CLIENTE%
"%CLIENTE%" -h %DB_HOST% -P %DB_PORT% -u %DB_USER% -N -s -e "SELECT VERSION()" > "%TMP_VER%" 2>nul
set "VER_SERVIDOR="
if not errorlevel 1 set /p VER_SERVIDOR=<"%TMP_VER%"
del "%TMP_VER%" >nul 2>&1
if not defined VER_SERVIDOR (
    echo [AVISO] No se pudo consultar la version del servidor ^(esta en marcha y son correctas las credenciales?^).
    goto :scripts
)
rem Algunas versiones anteponen "5.5.5-" ^(compatibilidad de replicacion^); se quita para comparar.
set "VER_NUM=%VER_SERVIDOR:5.5.5-=%"
set "VER_MAYOR=0" & set "VER_MENOR=0" & set "VER_PARCHE=0"
for /f "tokens=1-3 delims=.-" %%a in ("%VER_NUM%") do set "VER_MAYOR=%%a" & set "VER_MENOR=%%b" & set "VER_PARCHE=%%c"
set /a VER_TOTAL=VER_MAYOR*1000000+VER_MENOR*1000+VER_PARCHE 2>nul
if %VER_TOTAL% GEQ 10002001 (
    echo [OK] Servidor %VER_SERVIDOR% ^(se requiere MariaDB 10.2.1 o superior^).
) else (
    echo [AVISO] Servidor %VER_SERVIDOR%: los scripts requieren MariaDB 10.2.1 o superior y pueden fallar.
)

:scripts

for %%f in (sql\mariadb\glob_gusters.sql sql\mariadb\glob_gusters_insert.sql sql\mariadb\commands\01_DDL.sql sql\mariadb\commands\02_DML.sql sql\mariadb\commands\03_DQL.sql sql\mariadb\commands\04_VDL.sql sql\mariadb\commands\05_DCL.sql sql\mariadb\commands\06_TCL.sql) do (
    echo ^>^>^> %%f
    "%CLIENTE%" -h %DB_HOST% -P %DB_PORT% -u %DB_USER% --default-character-set=utf8mb4 < "%%f"
    if errorlevel 1 (
        echo [ERROR] Fallo %%f. Esta el servidor en marcha y son correctas las credenciales?
        exit /b 1
    )
)
echo [OK] Los 8 scripts SQL terminaron sin errores.

if "%PRUEBAS%"=="1" (
    echo ^>^>^> tests\mariadb\glob_gusters_test.sql ^(debe terminar con "PROYECTO OK"^)
    "%CLIENTE%" -h %DB_HOST% -P %DB_PORT% -u %DB_USER% --default-character-set=utf8mb4 --force %DB_NAME% < tests\mariadb\glob_gusters_test.sql
    if errorlevel 1 (
        echo [ERROR] Fallaron las pruebas.
        exit /b 1
    )
)

if "%DIAGNOSTICO%"=="1" (
    echo ^>^>^> sql\mariadb\check-mariadb.sql ^(diagnostico del servidor^)
    "%CLIENTE%" -h %DB_HOST% -P %DB_PORT% -u %DB_USER% --default-character-set=utf8mb4 --force "--init-command=SET @glob_gusters_db = '%DB_NAME%'" < sql\mariadb\check-mariadb.sql
    if errorlevel 1 echo [AVISO] El diagnostico termino con avisos ^(ver mensajes arriba^).
)
echo [OK] SQL completado.
exit /b 0
