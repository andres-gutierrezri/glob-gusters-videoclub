-- =====================================================================================
-- MariaDB Health Check Script — Glob-Gusters Video-Club
--
-- Diagnóstico del servidor MariaDB de XAMPP antes (o en cualquier momento) de
-- ejecutar el resto de scripts del proyecto: versión, conexión, estado del
-- servidor, configuración, motores de almacenamiento, cuentas de usuario y, en la
-- parte final, los objetos y datos específicos de la base de datos del proyecto
-- (`glob_gusters` por defecto; configurable con GLOB_GUSTERS_DB, ver más abajo).
--
-- SALIDA REDUCIDA (verificación de la conexión):
--   Por defecto solo se imprimen la verificación de la conexión y sus parámetros:
--   versión, host y puerto del servidor, cuenta autenticada, base seleccionada, id de
--   conexión y juego de caracteres/collation de la sesión. El resto del diagnóstico
--   (procesos, estado, configuración, motores, usuarios, objetos del proyecto y
--   rutinas) sigue en este archivo, dentro de un bloque de comentario /* ... */ al
--   final del script. Para volver a activarlo, borra la línea que abre el bloque
--   («/*» antes de «Procesos y conexiones activas») y la que lo cierra («*/» al final).
--   Las notas «LIMITACIONES CONOCIDAS» de más abajo aplican solo a ese diagnóstico.
--
-- REQUISITOS:
--   * Servidor MariaDB 10.2.1 o superior (verificado con 10.4.28, el de XAMPP) y cliente
--     `mariadb` (o `mysql`) en la terminal. Instalación y comandos por sistema operativo
--     (Windows, macOS y Linux): README.md, secciones «Dependencias requeridas» y «Guía de
--     ejecución por sistema operativo».
--
-- EJECUCIÓN SEGURA / IDEMPOTENCIA:
--   Todo el script es de sólo lectura (SELECT/SHOW): no modifica nada, así que se
--   puede ejecutar tantas veces como se quiera, en cualquier momento, sin ningún
--   efecto secundario ni riesgo para los datos.
--
-- TRES LIMITACIONES CONOCIDAS DEL ENTORNO (no son errores del script):
--   1) Las secciones marcadas más abajo como "requiere la base de datos
--      glob_gusters" fallarán con "ERROR 1049: Unknown database" /
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
--
-- CONFIGURACIÓN DESDE EL ARCHIVO .env:
--   Un archivo SQL no puede leer el .env por sí mismo. Por eso el nombre de la base de
--   datos del proyecto no está escrito en el script: se toma de la variable de sesión
--   @glob_gusters_db y, si no está definida, se usa 'glob_gusters'. El lanzador
--   sql/mariadb/check-mariadb.sh lee GLOB_GUSTERS_HOST, GLOB_GUSTERS_PORT,
--   GLOB_GUSTERS_USER, GLOB_GUSTERS_PASSWORD y GLOB_GUSTERS_DB del .env (o del entorno),
--   se conecta con ellos y define @glob_gusters_db antes de ejecutar este script:
--     sh sql/mariadb/check-mariadb.sh
-- =====================================================================================

-- Base de datos del proyecto que se revisa en las secciones 7 y 8: el valor que haya
-- definido el lanzador (a partir de GLOB_GUSTERS_DB) o 'glob_gusters' por defecto.
SET @db = COALESCE(@glob_gusters_db, 'glob_gusters');

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

-- Verificación de la conexión: si esta fila aparece, el cliente se conectó y el
-- servidor respondió. Muestra el id de la conexión y los parámetros de la sesión
-- (juego de caracteres del cliente y de la conexión, y collation de la conexión).
SELECT
    'Conexión OK' AS Estado,
    CONNECTION_ID() AS Id_Conexion,
    @@character_set_client AS Charset_Cliente,
    @@character_set_connection AS Charset_Conexion,
    @@collation_connection AS Collation_Conexion;

-- =====================================================================================
-- DIAGNÓSTICO COMPLETO DESACTIVADO (comentado): lo que sigue ya no se ejecuta. Se
-- conserva íntegro; ver «SALIDA REDUCIDA» en la cabecera para volver a activarlo.
-- =====================================================================================
/*
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
-- SECCIÓN 6: Usuarios del servidor.
-- No depende de mysql.proc ni de la base de datos del proyecto: User, Host y
-- plugin existen en mysql.user desde versiones muy antiguas de MySQL/MariaDB, así
-- que esta consulta es segura incluso si las tablas de sistema no se actualizaron.
-- ---------------------------------------------------------------------------------

-- Cuentas del servidor con su host de origen y el plugin de autenticación que
-- usan. Deliberadamente NO se usa SELECT * FROM mysql.user, porque esa tabla
-- incluye la columna authentication_string (el hash de la contraseña); listar
-- sólo estas columnas evita exponerlo en la salida del script.
SELECT host, user, plugin FROM mysql.user;

-- ---------------------------------------------------------------------------------
-- SECCIÓN 7: Objetos definidos en la base de datos del proyecto.
-- Requiere que la base (@db, por defecto `glob_gusters`) ya exista: ejecutar primero
-- sql/mariadb/glob_gusters.sql.
-- ---------------------------------------------------------------------------------
-- El nombre de la base viene de @db (GLOB_GUSTERS_DB del .env). USE no admite
-- parámetros ni sentencias preparadas, así que cada SHOW usa la forma `SHOW ... FROM
-- <base>` armada con CONCAT y ejecutada con PREPARE/EXECUTE. REPLACE duplica las comillas
-- invertidas del nombre para que no pueda romper el identificador entre `...`.

-- Tablas de la base de datos del proyecto (deben ser las 11 del modelo, más
-- cualquier tabla adicional creada por sql/mariadb/commands/01_DDL.sql).
SET @sql = CONCAT('SHOW TABLES FROM `', REPLACE(@db, '`', '``'), '`');
PREPARE consulta FROM @sql;
EXECUTE consulta;
DEALLOCATE PREPARE consulta;

-- Vistas definidas (deben ser v_ejemplares_detalle y v_clientes_con_aval, creadas
-- por sql/mariadb/commands/04_VDL.sql).
SET @sql = CONCAT('SHOW FULL TABLES FROM `', REPLACE(@db, '`', '``'), '` WHERE Table_type = \'VIEW\'');
PREPARE consulta FROM @sql;
EXECUTE consulta;
DEALLOCATE PREPARE consulta;

-- Triggers definidos (deben ser los cuatro de reglas de negocio de glob_gusters.sql:
-- trg_cliente_aval_diferente_insert, trg_cliente_aval_diferente_update,
-- trg_ejemplar_renta_max_4 y trg_ejemplar_renta_max_4_update).
SET @sql = CONCAT('SHOW TRIGGERS FROM `', REPLACE(@db, '`', '``'), '`');
PREPARE consulta FROM @sql;
EXECUTE consulta;
DEALLOCATE PREPARE consulta;

-- Eventos programados (el proyecto no define ninguno; se espera una lista vacía).
-- Puede fallar con ERROR 1577 si event_scheduler está en OFF (ver nota al inicio
-- del script); es el valor por defecto de XAMPP y no afecta a este proyecto.
SET @sql = CONCAT('SHOW EVENTS FROM `', REPLACE(@db, '`', '``'), '`');
PREPARE consulta FROM @sql;
EXECUTE consulta;
DEALLOCATE PREPARE consulta;

-- ---------------------------------------------------------------------------------
-- SECCIÓN 8: Estado específico del proyecto Glob-Gusters.
-- ---------------------------------------------------------------------------------

-- Confirma en information_schema si la base de datos del proyecto existe (devuelve
-- una fila si existe, ninguna si aún no se ha creado).
SELECT SCHEMA_NAME FROM information_schema.schemata WHERE SCHEMA_NAME = @db;

-- Resumen de cada tabla del proyecto con su cantidad aproximada de filas y su
-- tamaño en disco, para verificar de un vistazo que los datos de prueba se
-- cargaron correctamente.
SELECT
    table_name AS Tabla,
    table_rows AS Filas_Aprox,
    ROUND((data_length + index_length) / 1024, 1) AS Tamano_KB
FROM information_schema.tables
WHERE table_schema = @db
ORDER BY table_name;

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
*/
