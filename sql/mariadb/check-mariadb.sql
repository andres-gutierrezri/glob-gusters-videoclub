-- =====================================================================================
-- MariaDB Health Check Script — Glob-Gusters Video-Club
--
-- Diagnóstico del servidor MariaDB de XAMPP antes (o en cualquier momento) de
-- ejecutar el resto de scripts del proyecto: versión, conexión, estado del
-- servidor, configuración, motores de almacenamiento, objetos definidos, usuarios
-- y, al final, el estado específico de la base de datos `glob_gusters`.
--
-- EJECUCIÓN SEGURA / IDEMPOTENCIA:
--   Todo el script es de sólo lectura (SELECT/SHOW): no modifica nada, así que se
--   puede ejecutar tantas veces como se quiera, en cualquier momento, sin ningún
--   efecto secundario ni riesgo para los datos.
--
-- TRES LIMITACIONES CONOCIDAS DEL ENTORNO (no son errores del script):
--   1) Las secciones marcadas más abajo como "requiere la base de datos
--      glob_gusters" fallarán con "ERROR 1046: No database selected" /
--      "Unknown database 'glob_gusters'" si todavía no ejecutaste
--      sql/mariadb/glob_gusters.sql. Es esperado la primera vez que corres este
--      script; vuelve a ejecutarlo después de crear la base de datos, o usa
--      --force para que el cliente continúe con el resto de secciones igual.
--   2) SHOW EVENTS falla con "ERROR 1577: Cannot proceed, because event scheduler
--      is disabled" si la variable event_scheduler está en OFF, que es el valor
--      por defecto en una instalación de XAMPP recién instalada. No es un error
--      del proyecto (que no usa eventos); activar el planificador con
--      `SET GLOBAL event_scheduler = ON;` es opcional y no es necesario para nada
--      de este proyecto.
--   3) La última sección del script lee la tabla de sistema mysql.proc. En una
--      instalación de XAMPP donde el mysqld se reemplazó por una versión más
--      nueva sin correr mysql_upgrade, esa tabla queda con una estructura
--      desactualizada: SHOW PROCEDURE STATUS / SHOW FUNCTION STATUS /
--      information_schema.routines fallan con "ERROR 1558: Column count of
--      mysql.proc is wrong... Please use mysql_upgrade to fix this error". La
--      solución real es ejecutar `mysql_upgrade` (normalmente requiere permisos
--      de administrador/sudo sobre el directorio de datos de MariaDB); si no se
--      puede o no se quiere tocar el entorno, usa --force para que el script
--      reporte todo lo demás igual.
--
--   Ejemplo de ejecución que nunca se detiene por estas tres limitaciones:
--     mariadb -u root -p -h 127.0.0.1 -P 3306 --default-character-set=utf8mb4 \
--         --force < sql/mariadb/check-mariadb.sql
-- =====================================================================================

-- ---------------------------------------------------------------------------------
-- SECCIÓN 1: Identidad y versión del servidor (no requiere ninguna base de datos).
-- ---------------------------------------------------------------------------------

-- Versión de MariaDB tal como la reporta el servidor.
SELECT VERSION();

-- Versión, comentario de compilación, arquitectura y sistema operativo en una sola
-- fila, útil para copiar/pegar en un reporte de soporte.
SELECT @@version, @@version_comment, @@version_compile_machine, @@version_compile_os;

-- Nombre de host configurado en el servidor (identifica la instancia si hay varias).
SELECT @@hostname;

-- Puerto TCP en el que MariaDB está escuchando (por defecto 3306 en XAMPP).
SHOW VARIABLES LIKE 'port';

-- ---------------------------------------------------------------------------------
-- SECCIÓN 2: Conexión y sesión actual.
-- ---------------------------------------------------------------------------------

-- Cuenta con la que se autenticó esta conexión (usuario@host tal como lo ve el
-- servidor, que puede diferir del usuario pedido si hubo mapeo de autenticación).
SELECT CURRENT_USER();

-- Base de datos seleccionada actualmente en esta sesión (NULL si no se ha hecho
-- USE todavía, que es la situación normal la primera vez que se corre este script).
SELECT DATABASE();

-- Procesos y conexiones activas en el servidor en este momento.
SHOW PROCESSLIST;

-- ---------------------------------------------------------------------------------
-- SECCIÓN 3: Estado y actividad del servidor.
-- ---------------------------------------------------------------------------------

-- Tiempo (en segundos) que el servidor lleva encendido desde el último arranque.
SHOW STATUS LIKE 'Uptime';

-- Número de clientes conectados en este momento.
SHOW STATUS LIKE 'Threads_connected';

-- Total de consultas atendidas por el servidor desde que arrancó.
SHOW STATUS LIKE 'Questions';

-- Listado completo de variables de estado (cientos de filas); útil para
-- diagnósticos detallados de rendimiento, no sólo para una revisión rápida.
SHOW STATUS;

-- ---------------------------------------------------------------------------------
-- SECCIÓN 4: Configuración relevante para el proyecto Glob-Gusters.
-- ---------------------------------------------------------------------------------

-- Juegos de caracteres configurados en el servidor: deben incluir utf8mb4, que es
-- el que usa glob_gusters.sql al crear la base de datos.
SHOW VARIABLES LIKE 'character_set%';

-- Collations configuradas; glob_gusters.sql usa utf8mb4_general_ci en cada tabla.
SHOW VARIABLES LIKE 'collation%';

-- Modo SQL activo: afecta si restricciones como los CHECK de glob_gusters.sql
-- (chk_renta_fechas) se validan en modo estricto o se degradan a advertencia.
SHOW VARIABLES LIKE 'sql_mode';

-- Listado completo de variables de configuración del servidor (varios cientos de
-- filas); se deja al final de esta sección por su tamaño.
SHOW VARIABLES;

-- ---------------------------------------------------------------------------------
-- SECCIÓN 5: Motores de almacenamiento disponibles.
-- ---------------------------------------------------------------------------------

-- Confirma que InnoDB está disponible y es el motor por defecto: todas las tablas
-- de glob_gusters.sql lo requieren para las restricciones FOREIGN KEY.
SHOW ENGINES;

-- ---------------------------------------------------------------------------------
-- SECCIÓN 6: Objetos definidos en la base de datos del proyecto.
-- Requiere que `glob_gusters` ya exista (ejecutar primero sql/mariadb/glob_gusters.sql).
-- ---------------------------------------------------------------------------------

-- Selecciona `glob_gusters` como base de datos activa para las consultas SHOW
-- que siguen, ya que todas ellas requieren una base de datos seleccionada.
USE `glob_gusters`;

-- Tablas de la base de datos del proyecto (deben ser las 11 del modelo, más
-- cualquier tabla adicional creada por sql/mariadb/commands/01_DDL.sql).
SHOW TABLES;

-- Vistas definidas (deben ser v_ejemplares_detalle y v_clientes_con_aval, creadas
-- por sql/mariadb/commands/04_VDL.sql).
SHOW FULL TABLES WHERE Table_type = 'VIEW';

-- Triggers definidos (deben ser los tres de reglas de negocio de glob_gusters.sql:
-- trg_cliente_aval_diferente_insert, trg_cliente_aval_diferente_update y
-- trg_ejemplar_renta_max_4).
SHOW TRIGGERS;

-- Eventos programados (el proyecto no define ninguno; se espera una lista vacía).
-- Puede fallar con ERROR 1577 si event_scheduler está en OFF (ver nota al inicio
-- del script); es el valor por defecto de XAMPP y no afecta a este proyecto.
SHOW EVENTS;

-- ---------------------------------------------------------------------------------
-- SECCIÓN 7: Estado específico del proyecto Glob-Gusters.
-- ---------------------------------------------------------------------------------

-- Confirma en information_schema si la base de datos del proyecto existe (devuelve
-- una fila si existe, ninguna si aún no se ha creado).
SELECT SCHEMA_NAME FROM information_schema.schemata WHERE SCHEMA_NAME = 'glob_gusters';

-- Resumen de cada tabla del proyecto con su cantidad aproximada de filas y su
-- tamaño en disco, para verificar de un vistazo que los datos de prueba se
-- cargaron correctamente.
SELECT
    table_name AS Tabla,
    table_rows AS Filas_Aprox,
    ROUND((data_length + index_length) / 1024, 1) AS Tamano_KB
FROM information_schema.tables
WHERE table_schema = 'glob_gusters'
ORDER BY table_name;

-- ---------------------------------------------------------------------------------
-- SECCIÓN 8: Usuarios y seguridad (metadatos básicos, siempre disponibles).
-- ---------------------------------------------------------------------------------

-- Lista básica de cuentas de usuario, desde qué host pueden conectarse y con qué
-- método de autenticación (User, Host y plugin existen en mysql.user desde
-- versiones muy antiguas de MySQL/MariaDB, así que esta consulta es segura incluso
-- si las tablas de sistema no se actualizaron).
SELECT user, host, plugin FROM mysql.user;

-- ---------------------------------------------------------------------------------
-- SECCIÓN 9: Objetos que dependen de la tabla de sistema mysql.proc,
-- potencialmente desactualizada. Puede fallar con ERROR 1558 en instalaciones de
-- XAMPP sin mysql_upgrade (ver nota al inicio del script); se deja al final para
-- no bloquear el resto del reporte.
-- ---------------------------------------------------------------------------------

-- Procedimientos almacenados definidos en el servidor (el proyecto no usa ninguno
-- a propósito, para funcionar incluso con mysql.proc desactualizado).
SHOW PROCEDURE STATUS;

-- Funciones almacenadas definidas en el servidor (el proyecto no define ninguna).
SHOW FUNCTION STATUS;

-- Detalle crudo de rutinas (procedimientos y funciones) vía information_schema.
SELECT * FROM information_schema.routines LIMIT 10;

-- Lista de cuentas del servidor con su host de origen y el plugin de
-- autenticación que usan. Deliberadamente NO se usa SELECT * FROM mysql.user,
-- porque esa tabla incluye la columna authentication_string (el hash de la
-- contraseña); listar sólo estas columnas evita exponerlo en la salida del script.
SELECT host, user, plugin FROM mysql.user;

