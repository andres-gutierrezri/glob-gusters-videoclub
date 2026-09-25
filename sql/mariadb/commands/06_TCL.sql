-- =====================================================================================
-- 06_TCL.sql — Transaction Control Language
-- Objetivo: agrupar operaciones relacionadas en transacciones que aseguren la
-- integridad de los datos (COMMIT/ROLLBACK/SAVEPOINT).
-- Equivalente al ejemplo de "registrar contratos y firmas" del resumen de comandos,
-- adaptado a "registrar una renta junto con los ejemplares que se lleva el cliente".
--
-- CÓMO SE EJECUTA:
--   Debe correrse AL FINAL, después de 05_DCL.sql, cuando ya existen clientes y
--   ejemplares disponibles para poder registrar una renta de ejemplo.
-- =====================================================================================

USE `glob_gusters`;

-- ---------------------------------------------------------------------------------
-- START TRANSACTION: abre una transacción para que el encabezado de la renta y su
-- detalle (ejemplar_renta) se registren de forma atómica; si algo falla, ninguno
-- de los dos cambios queda aplicado.
-- ---------------------------------------------------------------------------------
START TRANSACTION;

-- Inserta el encabezado de la nueva renta para el cliente 4 (Andrés Torres).
INSERT INTO `renta` (`Cliente_ID`, `Inicia`, `Termina`)
VALUES (4, CURDATE(), NULL);

-- SAVEPOINT: marca un punto de control después de registrar el encabezado, por si
-- el detalle falla y sólo se necesita deshacer esa parte.
SAVEPOINT `sp_renta_creada`;

-- Inserta el detalle: el cliente 4 se lleva el ejemplar 5 (Interstellar, Bueno).
-- LAST_INSERT_ID() recupera el Renta_ID recién generado por la sentencia anterior.
INSERT INTO `ejemplar_renta` (`Renta_ID`, `Ejemplar_ID`, `Entrega`)
VALUES (LAST_INSERT_ID(), 5, NULL);

-- ---------------------------------------------------------------------------------
-- ROLLBACK TO SAVEPOINT (ejemplo comentado): si el detalle hubiera violado la
-- regla de los 4 ejemplares máximos (ver trigger trg_ejemplar_renta_max_4), se
-- podría deshacer sólo el detalle y conservar el encabezado con este comando.
-- ---------------------------------------------------------------------------------
-- ROLLBACK TO SAVEPOINT `sp_renta_creada`;

-- COMMIT: confirma de manera definitiva tanto el encabezado como el detalle de la
-- renta, ya que ambas inserciones se completaron sin errores.
COMMIT;

-- ---------------------------------------------------------------------------------
-- Segundo ejemplo: transacción que se deshace por completo con ROLLBACK, para
-- demostrar cómo se descartan cambios no confirmados.
-- ---------------------------------------------------------------------------------
START TRANSACTION;

-- Intento de actualización de prueba que finalmente no se quiere conservar.
UPDATE `cliente`
SET `Direccion` = 'Dirección temporal de prueba'
WHERE `Cliente_ID` = 1;

-- ROLLBACK: descarta la actualización anterior; la dirección de Laura Gómez queda
-- exactamente igual a como estaba antes de iniciar esta transacción.
ROLLBACK;
