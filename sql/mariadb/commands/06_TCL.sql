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
--
-- EJECUCIÓN SEGURA / IDEMPOTENCIA:
--   Sin una guarda, insertar una renta nueva en cada corrida iría acumulando
--   préstamos activos del mismo cliente hasta chocar con el trigger de máximo 4
--   ejemplares (trg_ejemplar_renta_max_4). Por eso, antes de insertar, se verifica en
--   la variable de sesión @ya_existe_tcl si el cliente de ejemplo ya tiene ese mismo
--   ejemplar prestado sin devolver; si es así, ambos INSERT se omiten (0 filas
--   afectadas, sin error) y sólo se repiten cuando corresponde. El cliente y el
--   ejemplar se localizan por su llave natural (DNI y película+número), no por un ID
--   numérico fijo.
-- =====================================================================================

USE `glob_gusters`;

-- Cliente de ejemplo: Andrés Torres, localizado por DNI (no por un Cliente_ID fijo).
SET @cliente_demo_tcl = (SELECT `Cliente_ID` FROM `cliente` WHERE `Dni` = '1000000004');

-- Ejemplar de ejemplo: Interstellar (2014), ejemplar número 2.
SET @ejemplar_demo_tcl = (
    SELECT e.`Ejemplar_ID` FROM `ejemplar` e
    INNER JOIN `pelicula` p ON p.`Pelicula_ID` = e.`Pelicula_ID`
    WHERE p.`Titulo` = 'Interstellar' AND p.`Anio` = 2014 AND e.`Numero` = 2
);

-- ¿El cliente de ejemplo ya tiene este ejemplar prestado sin devolver? Si es así, no
-- hace falta (ni conviene) volver a registrar el préstamo.
SET @ya_existe_tcl = EXISTS (
    SELECT 1 FROM `ejemplar_renta` er
    INNER JOIN `renta` r ON r.`Renta_ID` = er.`Renta_ID`
    WHERE r.`Cliente_ID` = @cliente_demo_tcl
      AND er.`Ejemplar_ID` = @ejemplar_demo_tcl
      AND er.`Entrega` IS NULL
);

-- ---------------------------------------------------------------------------------
-- START TRANSACTION: abre una transacción para que el encabezado de la renta y su
-- detalle (ejemplar_renta) se registren de forma atómica; si algo falla, ninguno
-- de los dos cambios queda aplicado.
-- ---------------------------------------------------------------------------------
START TRANSACTION;

-- Inserta el encabezado de la renta sólo si el préstamo de ejemplo aún no existe.
INSERT INTO `renta` (`Cliente_ID`, `Inicia`, `Termina`)
SELECT @cliente_demo_tcl, CURDATE(), NULL
FROM DUAL
WHERE NOT @ya_existe_tcl;

-- SAVEPOINT: marca un punto de control después de registrar el encabezado, por si
-- el detalle falla y sólo se necesita deshacer esa parte.
SAVEPOINT `sp_renta_creada`;

-- Inserta el detalle sólo si el encabezado anterior se llegó a crear en esta misma
-- corrida; LAST_INSERT_ID() recupera el Renta_ID que acaba de generar ese INSERT.
INSERT INTO `ejemplar_renta` (`Renta_ID`, `Ejemplar_ID`, `Entrega`)
SELECT LAST_INSERT_ID(), @ejemplar_demo_tcl, NULL
FROM DUAL
WHERE NOT @ya_existe_tcl;

-- ---------------------------------------------------------------------------------
-- ROLLBACK TO SAVEPOINT (ejemplo comentado): si el detalle hubiera violado la
-- regla de los 4 ejemplares máximos (ver trigger trg_ejemplar_renta_max_4), se
-- podría deshacer sólo el detalle y conservar el encabezado con este comando.
-- ---------------------------------------------------------------------------------
-- ROLLBACK TO SAVEPOINT `sp_renta_creada`;

-- COMMIT: confirma de manera definitiva tanto el encabezado como el detalle de la
-- renta (o no confirma nada nuevo, si ya existía y ambos INSERT se omitieron).
COMMIT;

-- ---------------------------------------------------------------------------------
-- Segundo ejemplo: transacción que se deshace por completo con ROLLBACK, para
-- demostrar cómo se descartan cambios no confirmados. Al terminar siempre en
-- ROLLBACK, esta transacción no deja ningún efecto persistente y es segura de
-- repetir cuantas veces se quiera.
-- ---------------------------------------------------------------------------------
START TRANSACTION;

-- Intento de actualización de prueba que finalmente no se quiere conservar.
UPDATE `cliente`
SET `Direccion` = 'Dirección temporal de prueba'
WHERE `Dni` = '1000000001';

-- ROLLBACK: descarta la actualización anterior; la dirección de Laura Gómez queda
-- exactamente igual a como estaba antes de iniciar esta transacción.
ROLLBACK;
