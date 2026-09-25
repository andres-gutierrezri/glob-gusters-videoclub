-- =====================================================================================
-- 02_DML.sql — Data Manipulation Language
-- Objetivo: manipular los datos ya cargados en la base de datos Glob-Gusters.
-- Incluye: INSERT (nuevo socio), UPDATE (cambio de estado de un ejemplar) y
-- DELETE (eliminación de un registro de reparto).
--
-- CÓMO SE EJECUTA:
--   Debe correrse DESPUÉS de glob_gusters_insert.sql (los datos de ejemplo ya deben
--   existir) y de 01_DDL.sql (la columna `Email` de `cliente` ya debe existir).
-- =====================================================================================

USE `glob_gusters`;

-- ---------------------------------------------------------------------------------
-- INSERT: registra un nuevo socio (cliente) avalado por un socio ya existente
-- (Aval_Cliente_ID = 1 → Laura Gómez) e incluye el correo agregado en 01_DDL.sql.
-- ---------------------------------------------------------------------------------
INSERT INTO `cliente` (`Dni`, `Nombre`, `Direccion`, `Telefono`, `Aval_Cliente_ID`, `Email`)
VALUES ('1000000005', 'Sofía Ramírez', 'Calle 50 # 20-30', '3011122334', 1, 'sofia.ramirez@example.com');

-- ---------------------------------------------------------------------------------
-- UPDATE: actualiza el estado de conservación de un ejemplar que fue devuelto con
-- daños (Estado_ID = 4 → 'Dañado'), identificado por su Ejemplar_ID.
-- ---------------------------------------------------------------------------------
UPDATE `ejemplar`
SET `Estado_ID` = 4
WHERE `Ejemplar_ID` = 2;

-- ---------------------------------------------------------------------------------
-- UPDATE: corrige la duración de "Interstellar", agregada como columna nueva en
-- 01_DDL.sql y que llegó vacía (NULL) desde la carga inicial de datos.
-- ---------------------------------------------------------------------------------
UPDATE `pelicula`
SET `Duracion_Minutos` = 169
WHERE `Titulo` = 'Interstellar';

-- ---------------------------------------------------------------------------------
-- DELETE: elimina un registro de reparto ingresado por error (un actor que en
-- realidad no participó en la película indicada).
-- ---------------------------------------------------------------------------------
DELETE FROM `reparto`
WHERE `Pelicula_ID` = 3 AND `Actor_ID` = 5;
