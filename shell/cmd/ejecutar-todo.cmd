@echo off
rem ====================================================================================
rem ejecutar-todo.cmd - Ejecuta SQL, Python y Java en orden (Windows CMD)
rem ====================================================================================
rem Llama a ejecutar-sql.cmd, ejecutar-python.cmd y ejecutar-java.cmd, y se detiene en
rem el primer fallo de SQL o Java ^(si Python falla, avisa y continua con Java^). Acepta --sin-python y --sin-java para omitir un lenguaje.
rem
rem Uso (desde cualquier carpeta):
rem     shell\cmd\ejecutar-todo.cmd [--sin-python] [--sin-java]
rem ====================================================================================
setlocal
set "PY=1"
set "JV=1"
:args
if "%~1"=="" goto :inicio
if "%~1"=="--sin-python" set "PY=0"
if "%~1"=="--sin-java" set "JV=0"
shift
goto :args

:inicio
call "%~dp0ejecutar-sql.cmd"
if errorlevel 1 exit /b 1
set "PY_FALLO=0"
if "%PY%"=="1" (
    call "%~dp0ejecutar-python.cmd"
    if errorlevel 1 (
        set "PY_FALLO=1"
        echo [AVISO] Los scripts de Python se detuvieron ^(entorno virtual, dependencias o ejecucion^). Se continua con Java.
    )
)
if "%JV%"=="1" (
    call "%~dp0ejecutar-java.cmd"
    if errorlevel 1 exit /b 1
)
if "%PY_FALLO%"=="1" (
    echo [AVISO] Proyecto ejecutado con advertencias: SQL y Java terminaron bien, pero Python no se completo.
    exit /b 0
)
echo [OK] Todo el proyecto se ejecuto correctamente.
exit /b 0
