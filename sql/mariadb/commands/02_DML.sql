-- =====================================================================================
-- 02_DML.sql — Data Manipulation Language
-- Objetivo: manipular los datos ya cargados en la base de datos Glob-Gusters.
-- Incluye: INSERT (nuevo socio), UPDATE (cambio de estado de un ejemplar) y
-- DELETE (eliminación de un registro de reparto).
--
-- CÓMO SE EJECUTA:
--   Debe correrse DESPUÉS de glob_gusters_insert.sql (los datos de ejemplo ya deben
--   existir) y de 01_DDL.sql (la columna `Email` de `cliente` ya debe existir).
--
-- EJECUCIÓN SEGURA / IDEMPOTENCIA:
--   Ninguna sentencia usa IDs numéricos fijos: los registros se localizan por su
--   llave natural (Titulo+Anio para pelicula, Numero de ejemplar dentro de su
--   película, Nombre de actor), para no depender del orden exacto en que se hayan
--   generado los AUTO_INCREMENT en una corrida anterior. El INSERT usa IGNORE (la
--   tabla cliente tiene UNIQUE en Dni), y los UPDATE/DELETE son naturalmente
--   idempotentes: repetirlos no cambia el resultado ni genera error.
-- =====================================================================================

USE `glob_gusters`;

-- ---------------------------------------------------------------------------------
-- INSERT: registra un nuevo socio (cliente) avalado por un socio ya existente
-- (Laura Gómez, localizada por su DNI) e incluye el correo agregado en 01_DDL.sql.
-- IGNORE evita el error de duplicado si el script se ejecuta más de una vez (Dni es
-- UNIQUE); es seguro aquí porque el aval no coincide con el propio registro, así que
-- el trigger trg_cliente_aval_diferente_insert nunca se dispara para esta fila.
-- ---------------------------------------------------------------------------------
-- Nota: la subconsulta del aval se envuelve en una tabla derivada porque MariaDB no
-- permite que un INSERT referencie directamente en VALUES() la misma tabla en la que
-- se está insertando (ERROR 1093: "Table 'cliente' is specified twice").
INSERT IGNORE INTO `cliente` (`Dni`, `Nombre`, `Direccion`, `Telefono`, `Aval_Cliente_ID`, `Email`)
VALUES (
    '1000000005', 'Sofía Ramírez', 'Calle 50 # 20-30', '3011122334',
    (SELECT `Cliente_ID` FROM (SELECT `Cliente_ID` FROM `cliente` WHERE `Dni` = '1000000001') AS `aval`),
    'sofia.ramirez@example.com'
);

-- ---------------------------------------------------------------------------------
-- UPDATE: actualiza el estado de conservación de un ejemplar que fue devuelto con
-- daños ('Dañado'), identificado por su llave natural (película + número de
-- ejemplar) en vez de un Ejemplar_ID fijo. Repetir este UPDATE no tiene efecto
-- adicional: el segundo intento deja el mismo valor que ya había.
-- ---------------------------------------------------------------------------------
UPDATE `ejemplar` e
INNER JOIN `pelicula` p ON p.`Pelicula_ID` = e.`Pelicula_ID`
SET e.`Estado_ID` = (SELECT `Estado_ID` FROM `estado` WHERE `Nombre` = 'Dañado')
WHERE p.`Titulo` = 'Quo Vadis' AND p.`Anio` = 1951 AND e.`Numero` = 2;

-- ---------------------------------------------------------------------------------
-- UPDATE: corrige la duración de "Interstellar" (2014), agregada como columna nueva
-- en 01_DDL.sql y que llegó vacía (NULL) desde la carga inicial de datos. Repetirlo
-- deja el mismo valor, sin error.
-- ---------------------------------------------------------------------------------
UPDATE `pelicula`
SET `Duracion_Minutos` = 169
WHERE `Titulo` = 'Interstellar' AND `Anio` = 2014;

-- ---------------------------------------------------------------------------------
-- DELETE: elimina el registro de reparto de Anne Hathaway en Interstellar (2014),
-- ingresado por error. Eliminar una fila que ya no existe no genera error: repetir
-- este DELETE en una segunda corrida simplemente no afecta ninguna fila.
-- ---------------------------------------------------------------------------------
DELETE r FROM `reparto` r
INNER JOIN `pelicula` p ON p.`Pelicula_ID` = r.`Pelicula_ID`
INNER JOIN `actor` a ON a.`Actor_ID` = r.`Actor_ID`
WHERE p.`Titulo` = 'Interstellar' AND p.`Anio` = 2014 AND a.`Nombre` = 'Anne Hathaway';
