@echo off
rem ====================================================================================
rem ejecutar-sql.cmd - Ejecuta todos los scripts SQL de MariaDB (Windows CMD)
rem ====================================================================================
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
