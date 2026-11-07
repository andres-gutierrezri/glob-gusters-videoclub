@echo off
rem ====================================================================================
rem ejecutar-python.cmd - Ejecuta todos los scripts de py\ (Windows CMD)
rem ====================================================================================
rem Crea el entorno virtual .venv si no existe, actualiza pip, instala requirements.txt y ejecuta, en
rem orden: conexion, ddl, dml, dql, vdl, dcl, tcl y conexion_mariabd. Requiere que la
rem base ya exista (ejecutar-sql.cmd) y Python 3.9+.
rem
rem Si el paquete mariadb no se puede instalar (falta MariaDB Connector/C), se instala
rem solo PyMySQL y se omite conexion_mariabd.py con un aviso; el resto funciona igual.
rem
rem Uso (desde cualquier carpeta):
rem     shell\cmd\ejecutar-python.cmd
rem ====================================================================================
setlocal
call "%~dp0lib.cmd" || exit /b 1
cd /d "%RAIZ%"
if not exist ".env" (
    copy ".env.example" ".env" >nul
    echo [AVISO] Se creo .env a partir de .env.example. Si tu usuario tiene contrasena, edita GLOB_GUSTERS_PASSWORD.
)

set "VPY=.venv\Scripts\python.exe"
echo ^>^>^> Verificando el entorno virtual .venv
if exist "%VPY%" (
    echo [OK] El entorno virtual .venv ya existe.
    goto :dependencias
)
echo ^>^>^> El entorno virtual .venv no existe; creandolo

rem Busca un Python 3.9+ real (ignora el alias vacio de la Tienda de Windows).
set "PY="
if defined PYTHON_BIN set "PY=%PYTHON_BIN%"
if not defined PY for %%c in (py python python3) do if not defined PY %%c -c "import sys; sys.exit(0 if sys.version_info >= (3, 9) else 1)" >nul 2>&1 && set "PY=%%c"
if not defined PY (
    echo [ERROR] No se encontro Python 3.9+. Instalalo ^(winget install Python.Python.3.13^) o define PYTHON_BIN.
    exit /b 1
)
echo ^>^>^> Creando el entorno virtual .venv
"%PY%" -m venv .venv
if errorlevel 1 goto :venv_falla
if not exist "%VPY%" goto :venv_falla
echo [OK] Entorno virtual .venv creado correctamente.
goto :dependencias

:venv_falla
echo [AVISO] No se pudo crear el entorno virtual .venv. Se detiene la ejecucion.
echo [ERROR] Sin entorno virtual no se instalan las dependencias ni se ejecutan los scripts de Python.
exit /b 1

:dependencias
echo ^>^>^> Actualizando pip
"%VPY%" -m pip install --quiet --upgrade pip
if errorlevel 1 echo [AVISO] No se pudo actualizar pip ^(sin conexion a Internet?^). Se continua con la version actual.

echo ^>^>^> Instalando dependencias ^(requirements.txt^)
set "CON_MARIADB=1"
"%VPY%" -m pip install --quiet -r requirements.txt
if errorlevel 1 (
    echo [AVISO] No se pudo instalar el paquete mariadb ^(necesita MariaDB Connector/C 3.3.1 o superior^). Se instala solo PyMySQL.
    "%VPY%" -m pip install --quiet "PyMySQL>=1.1"
    if errorlevel 1 (
        echo [ERROR] Fallo la instalacion de PyMySQL.
        exit /b 1
    )
    set "CON_MARIADB=0"
)

echo ^>^>^> Dependencias de Python instaladas en .venv ^(paquete y version^)
"%VPY%" -m pip list --format=columns
if errorlevel 1 echo [AVISO] No se pudo listar las dependencias instaladas.

set "PYTHONIOENCODING=utf-8"
for %%m in (conexion ddl dml dql vdl dcl tcl conexion_mariabd) do (
    call :ejecutar %%m
    if errorlevel 1 exit /b 1
)
echo [OK] Python completado.
exit /b 0

:ejecutar
if "%1"=="conexion_mariabd" if "%CON_MARIADB%"=="0" (
    echo [AVISO] Se omite py\conexion_mariabd.py ^(requiere el paquete mariadb^).
    exit /b 0
)
echo ^>^>^> py\%1.py
"%VPY%" py\%1.py
if errorlevel 1 (
    echo [ERROR] Fallo py\%1.py
    exit /b 1
)
exit /b 0
