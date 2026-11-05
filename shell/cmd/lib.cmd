@echo off
rem ====================================================================================
rem lib.cmd - Configuracion comun de los lanzadores de CMD (Windows)
rem ====================================================================================
rem No se ejecuta directamente: los demas scripts de esta carpeta lo cargan con
rem     call "%~dp0lib.cmd"
rem
rem Deja definidas estas variables:
rem     RAIZ       Raiz del proyecto (dos niveles sobre shell\cmd\).
rem     DB_HOST, DB_PORT, DB_USER, DB_NAME   Datos de conexion.
rem     MYSQL_PWD  Contrasena (solo si existe); el cliente la lee de aqui.
rem     CLIENTE    Ruta o nombre del cliente mariadb.exe (solo con CHECK_CLIENTE=1).
rem Prioridad de los valores: variable del sistema > archivo .env > valor por defecto.
rem Variables de conexion: GLOB_GUSTERS_HOST, _PORT, _USER, _PASSWORD y _DB (las mismas
rem que usan py\conexion.py y java\Conexion.java). MARIADB_BIN indica el cliente.
rem ====================================================================================
chcp 65001 >nul
for %%i in ("%~dp0..\..") do set "RAIZ=%%~fi"

if defined GLOB_GUSTERS_HOST set "DB_HOST=%GLOB_GUSTERS_HOST%"
if not defined GLOB_GUSTERS_HOST call :leer GLOB_GUSTERS_HOST localhost DB_HOST
if defined GLOB_GUSTERS_PORT set "DB_PORT=%GLOB_GUSTERS_PORT%"
if not defined GLOB_GUSTERS_PORT call :leer GLOB_GUSTERS_PORT 3306 DB_PORT
if defined GLOB_GUSTERS_USER set "DB_USER=%GLOB_GUSTERS_USER%"
if not defined GLOB_GUSTERS_USER call :leer GLOB_GUSTERS_USER root DB_USER
if defined GLOB_GUSTERS_DB set "DB_NAME=%GLOB_GUSTERS_DB%"
if not defined GLOB_GUSTERS_DB call :leer GLOB_GUSTERS_DB glob_gusters DB_NAME
set "DB_PASS="
if defined GLOB_GUSTERS_PASSWORD set "DB_PASS=%GLOB_GUSTERS_PASSWORD%"
if not defined GLOB_GUSTERS_PASSWORD call :leer GLOB_GUSTERS_PASSWORD "" DB_PASS

rem Con "localhost" el cliente podria usar otro canal local; se fuerza TCP con 127.0.0.1.
if /i "%DB_HOST%"=="localhost" set "DB_HOST=127.0.0.1"
rem El cliente lee la contrasena de MYSQL_PWD: asi no aparece en la lista de procesos.
if defined DB_PASS set "MYSQL_PWD=%DB_PASS%"

if not "%CHECK_CLIENTE%"=="1" exit /b 0

rem Localiza el cliente: MARIADB_BIN, el del PATH o la ruta tipica de XAMPP.
set "CLIENTE="
if defined MARIADB_BIN set "CLIENTE=%MARIADB_BIN%"
if not defined CLIENTE where mariadb >nul 2>&1 && set "CLIENTE=mariadb"
if not defined CLIENTE where mysql >nul 2>&1 && set "CLIENTE=mysql"
if not defined CLIENTE if exist "C:\xampp\mysql\bin\mariadb.exe" set "CLIENTE=C:\xampp\mysql\bin\mariadb.exe"
if not defined CLIENTE (
    echo [ERROR] No se encontro el cliente mariadb. Agrega C:\xampp\mysql\bin al PATH o define MARIADB_BIN.
    echo [ERROR] Ejemplo: set MARIADB_BIN=C:\xampp\mysql\bin\mariadb.exe
    exit /b 1
)
exit /b 0

rem leer CLAVE DEFECTO VARIABLE: guarda en VARIABLE el valor de CLAVE en el .env o, si no
rem esta o esta vacio, DEFECTO. Solo lee texto: no ejecuta nada de lo que haya en el archivo.
:leer
set "%~3=%~2"
if not exist "%RAIZ%\.env" exit /b 0
for /f "usebackq tokens=1,* delims==" %%a in ("%RAIZ%\.env") do if /i "%%a"=="%~1" if not "%%~b"=="" set "%~3=%%~b"
exit /b 0
