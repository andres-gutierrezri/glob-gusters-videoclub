-- =====================================================================================
-- 05_DCL.sql — Data Control Language
-- Objetivo: gestionar permisos y accesos a la base de datos Glob-Gusters.
-- Incluye: creación de usuario, GRANT de permisos de lectura, REVOKE de permisos de
-- borrado y consulta de privilegios existentes.
--
-- CÓMO SE EJECUTA:
--   Debe correrse DESPUÉS de 04_VDL.sql, cuando la estructura, los datos y las vistas
--   ya están listos para ser consultados por otros usuarios. Requiere ejecutarse con
--   un usuario con privilegios administrativos (por defecto, `root` en XAMPP).
--
-- EJECUCIÓN SEGURA / IDEMPOTENCIA:
--   CREATE USER usa IF NOT EXISTS; GRANT vuelve a otorgar los mismos privilegios sin
--   error si ya estaban concedidos; y REVOKE DELETE es seguro de repetir siempre que
--   el usuario ya tenga al menos un privilegio otorgado en ese esquema (lo garantiza
--   el GRANT anterior en este mismo script). Verificado ejecutando el script dos
--   veces seguidas sin reiniciar la base de datos.
-- =====================================================================================

-- No se antepone USE porque GRANT/CREATE USER son sentencias a nivel de servidor,
-- pero los privilegios sí se otorgan explícitamente sobre el esquema `glob_gusters`.

-- ---------------------------------------------------------------------------------
-- CREATE USER: crea un usuario de aplicación de sólo lectura para reportes,
-- válido únicamente desde el host local (típico en un entorno XAMPP de desarrollo).
-- ---------------------------------------------------------------------------------
CREATE USER IF NOT EXISTS 'glob_gusters_reportes'@'localhost' IDENTIFIED BY 'Reportes#2024';

-- ---------------------------------------------------------------------------------
-- GRANT: otorga permisos de sólo lectura (SELECT) sobre todas las tablas y vistas
-- del esquema del proyecto, suficiente para generar reportes sin modificar datos.
-- ---------------------------------------------------------------------------------
GRANT SELECT ON `glob_gusters`.* TO 'glob_gusters_reportes'@'localhost';

-- ---------------------------------------------------------------------------------
-- CREATE USER: crea un segundo usuario de aplicación con permisos operativos
-- (lectura y escritura) para el personal que atiende el mostrador del video-club.
-- ---------------------------------------------------------------------------------
CREATE USER IF NOT EXISTS 'glob_gusters_mostrador'@'localhost' IDENTIFIED BY 'Mostrador#2024';

-- ---------------------------------------------------------------------------------
-- GRANT: otorga permisos de lectura, inserción y actualización, pero sin borrado,
-- ya que el personal de mostrador no debería poder eliminar historial de rentas.
-- ---------------------------------------------------------------------------------
GRANT SELECT, INSERT, UPDATE ON `glob_gusters`.* TO 'glob_gusters_mostrador'@'localhost';

-- ---------------------------------------------------------------------------------
-- REVOKE: revoca explícitamente el permiso de borrado (DELETE) por si el usuario
-- lo hubiera tenido de una asignación anterior; refuerza la regla del negocio.
-- ---------------------------------------------------------------------------------
REVOKE DELETE ON `glob_gusters`.* FROM 'glob_gusters_mostrador'@'localhost';

-- ---------------------------------------------------------------------------------
-- FLUSH PRIVILEGES: recarga las tablas de privilegios en memoria para que los
-- cambios de GRANT/REVOKE tengan efecto inmediato en la sesión del servidor.
-- ---------------------------------------------------------------------------------
FLUSH PRIVILEGES;

-- ---------------------------------------------------------------------------------
-- SELECT de verificación: consulta los privilegios efectivos otorgados a cada
-- usuario recién creado.
-- ---------------------------------------------------------------------------------
SHOW GRANTS FOR 'glob_gusters_reportes'@'localhost';
SHOW GRANTS FOR 'glob_gusters_mostrador'@'localhost';
