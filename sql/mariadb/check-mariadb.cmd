@echo off
rem ====================================================================================
rem check-mariadb.cmd - Lanzador de check-mariadb.sql con la configuracion del .env
rem ====================================================================================
rem Un archivo SQL no puede leer el .env, asi que este script lo hace por el: lee las
rem variables de conexion, ejecuta el cliente mariadb con ellas y le pasa a
rem check-mariadb.sql el nombre de la base de datos mediante la variable de sesion
rem @glob_gusters_db. Es el equivalente en CMD de check-mariadb.sh.
rem
rem Variables que usa (las mismas de py\conexion.py y java\Conexion.java):
rem     GLOB_GUSTERS_HOST (localhost), GLOB_GUSTERS_PORT (3306), GLOB_GUSTERS_USER (root),
rem     GLOB_GUSTERS_PASSWORD (vacia = sin contrasena) y GLOB_GUSTERS_DB (glob_gusters).
rem Prioridad: variable ya definida en el sistema > archivo .env > valor por defecto.
rem Ademas, MARIADB_BIN permite indicar la ruta del cliente mariadb (opcional).
rem La lectura del .env y la busqueda del cliente las hace shell\cmd\lib.cmd.
rem
rem Uso (desde cualquier carpeta):
rem     sql\mariadb\check-mariadb.cmd
rem ====================================================================================
setlocal
set "CHECK_CLIENTE=1"
call "%~dp0..\..\shell\cmd\lib.cmd" || exit /b 1
cd /d "%RAIZ%"

rem Ejecuta el script con --force (para que las secciones que fallen por las limitaciones
rem conocidas del entorno no detengan el reporte). --init-command define @glob_gusters_db
rem nada mas conectar, antes de leer check-mariadb.sql de la entrada estandar.
"%CLIENTE%" -h %DB_HOST% -P %DB_PORT% -u %DB_USER% --default-character-set=utf8mb4 --force --init-command="SET @glob_gusters_db = '%DB_NAME%'" < sql\mariadb\check-mariadb.sql
exit /b %errorlevel%
