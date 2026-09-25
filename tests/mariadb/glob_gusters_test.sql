-- =====================================================================================
-- glob_gusters_test.sql — Pruebas de integridad integral del proyecto
-- Autor: Andrés Felipe Gutiérrez Rivera
--
-- Verifica que el proyecto completo (estructura, datos, vistas y reglas de negocio)
-- quedó correctamente desplegado en MariaDB. No usa procedimientos almacenados (para
-- funcionar incluso en instalaciones de XAMPP con la tabla de sistema mysql.proc
-- desactualizada, un problema común al usar un mysqld más nuevo que la instalación
-- original). En su lugar, las pruebas que deben fallar se ejecutan como INSERT
-- individuales que MariaDB rechaza por trigger o CHECK; el script se ejecuta con la
-- bandera --force para poder seguir evaluando después de esos errores esperados, y
-- cada prueba negativa se verifica y se limpia con una consulta posterior.
--
-- CÓMO SE EJECUTA (obligatorio usar --force, ver motivo arriba):
--   Debe correrse DESPUÉS de haber ejecutado, en orden, los ocho scripts descritos en
--   el README (glob_gusters.sql, glob_gusters_insert.sql y commands/01 a 06).
--
--   mariadb -u root -p -h 127.0.0.1 -P 3306 --default-character-set=utf8mb4 \
--       --force glob_gusters < tests/mariadb/glob_gusters_test.sql
--
-- El resultado final es una tabla con una fila por prueba (PASS/FAIL) y un resumen
-- con el total de pruebas aprobadas y fallidas.
--
-- EJECUCIÓN SEGURA / IDEMPOTENCIA:
--   Este script puede ejecutarse varias veces seguidas sin dejar residuos: cada
--   prueba que inserta datos (cliente/renta/ejemplar_renta de prueba) primero borra
--   cualquier resto de una corrida anterior interrumpida antes de insertar, y limpia
--   lo que generó al final. La tabla `test_results` es TEMPORARY (vive sólo en la
--   sesión actual) y se elimina explícitamente al terminar.
-- =====================================================================================

USE `glob_gusters`;

-- Tabla temporal (vive sólo durante esta sesión) donde se acumulan los resultados.
CREATE TEMPORARY TABLE `test_results` (
    `Test_ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `Nombre_Prueba` VARCHAR(150) NOT NULL,
    `Resultado` ENUM('PASS', 'FAIL') NOT NULL,
    `Detalle` VARCHAR(255) NULL,
    PRIMARY KEY (`Test_ID`)
);

-- ---------------------------------------------------------------------------------
-- PRUEBA 1: existen las 11 tablas base del modelo.
-- ---------------------------------------------------------------------------------
INSERT INTO `test_results` (`Nombre_Prueba`, `Resultado`, `Detalle`)
SELECT
    'Existen las 11 tablas base del modelo',
    IF(COUNT(*) = 11, 'PASS', 'FAIL'),
    CONCAT('Tablas encontradas: ', COUNT(*))
FROM `information_schema`.`tables`
WHERE `table_schema` = 'glob_gusters' AND `table_type` = 'BASE TABLE';

-- ---------------------------------------------------------------------------------
-- PRUEBA 2: existen las 2 vistas definidas en 04_VDL.sql.
-- ---------------------------------------------------------------------------------
INSERT INTO `test_results` (`Nombre_Prueba`, `Resultado`, `Detalle`)
SELECT
    'Existen las 2 vistas del proyecto',
    IF(COUNT(*) = 2, 'PASS', 'FAIL'),
    CONCAT('Vistas encontradas: ', COUNT(*))
FROM `information_schema`.`tables`
WHERE `table_schema` = 'glob_gusters' AND `table_type` = 'VIEW';

-- ---------------------------------------------------------------------------------
-- PRUEBA 3: existen los 3 triggers de reglas de negocio.
-- ---------------------------------------------------------------------------------
INSERT INTO `test_results` (`Nombre_Prueba`, `Resultado`, `Detalle`)
SELECT
    'Existen los 3 triggers de reglas de negocio',
    IF(COUNT(*) = 3, 'PASS', 'FAIL'),
    CONCAT('Triggers encontrados: ', COUNT(*))
FROM `information_schema`.`triggers`
WHERE `trigger_schema` = 'glob_gusters';

-- ---------------------------------------------------------------------------------
-- PRUEBA 4: cada tabla base tiene al menos un registro cargado (datos de prueba).
-- ---------------------------------------------------------------------------------
INSERT INTO `test_results` (`Nombre_Prueba`, `Resultado`, `Detalle`)
SELECT 'Tabla nacionalidad tiene datos', IF(COUNT(*) > 0, 'PASS', 'FAIL'), CONCAT('Filas: ', COUNT(*)) FROM `nacionalidad`;
INSERT INTO `test_results` (`Nombre_Prueba`, `Resultado`, `Detalle`)
SELECT 'Tabla productora tiene datos', IF(COUNT(*) > 0, 'PASS', 'FAIL'), CONCAT('Filas: ', COUNT(*)) FROM `productora`;
INSERT INTO `test_results` (`Nombre_Prueba`, `Resultado`, `Detalle`)
SELECT 'Tabla estado tiene datos', IF(COUNT(*) > 0, 'PASS', 'FAIL'), CONCAT('Filas: ', COUNT(*)) FROM `estado`;
INSERT INTO `test_results` (`Nombre_Prueba`, `Resultado`, `Detalle`)
SELECT 'Tabla director tiene datos', IF(COUNT(*) > 0, 'PASS', 'FAIL'), CONCAT('Filas: ', COUNT(*)) FROM `director`;
INSERT INTO `test_results` (`Nombre_Prueba`, `Resultado`, `Detalle`)
SELECT 'Tabla pelicula tiene datos', IF(COUNT(*) > 0, 'PASS', 'FAIL'), CONCAT('Filas: ', COUNT(*)) FROM `pelicula`;
INSERT INTO `test_results` (`Nombre_Prueba`, `Resultado`, `Detalle`)
SELECT 'Tabla actor tiene datos', IF(COUNT(*) > 0, 'PASS', 'FAIL'), CONCAT('Filas: ', COUNT(*)) FROM `actor`;
INSERT INTO `test_results` (`Nombre_Prueba`, `Resultado`, `Detalle`)
SELECT 'Tabla reparto tiene datos', IF(COUNT(*) > 0, 'PASS', 'FAIL'), CONCAT('Filas: ', COUNT(*)) FROM `reparto`;
INSERT INTO `test_results` (`Nombre_Prueba`, `Resultado`, `Detalle`)
SELECT 'Tabla cliente tiene datos', IF(COUNT(*) > 0, 'PASS', 'FAIL'), CONCAT('Filas: ', COUNT(*)) FROM `cliente`;
INSERT INTO `test_results` (`Nombre_Prueba`, `Resultado`, `Detalle`)
SELECT 'Tabla ejemplar tiene datos', IF(COUNT(*) > 0, 'PASS', 'FAIL'), CONCAT('Filas: ', COUNT(*)) FROM `ejemplar`;
INSERT INTO `test_results` (`Nombre_Prueba`, `Resultado`, `Detalle`)
SELECT 'Tabla renta tiene datos', IF(COUNT(*) > 0, 'PASS', 'FAIL'), CONCAT('Filas: ', COUNT(*)) FROM `renta`;
INSERT INTO `test_results` (`Nombre_Prueba`, `Resultado`, `Detalle`)
SELECT 'Tabla ejemplar_renta tiene datos', IF(COUNT(*) > 0, 'PASS', 'FAIL'), CONCAT('Filas: ', COUNT(*)) FROM `ejemplar_renta`;

-- ---------------------------------------------------------------------------------
-- PRUEBA 5: no existen registros huérfanos (integridad referencial real de los datos,
-- más allá de las restricciones FK que ya lo impedirían).
-- ---------------------------------------------------------------------------------
INSERT INTO `test_results` (`Nombre_Prueba`, `Resultado`, `Detalle`)
SELECT
    'No hay ejemplares huérfanos (sin película válida)',
    IF(COUNT(*) = 0, 'PASS', 'FAIL'),
    CONCAT('Huérfanos: ', COUNT(*))
FROM `ejemplar` e
LEFT JOIN `pelicula` p ON p.`Pelicula_ID` = e.`Pelicula_ID`
WHERE p.`Pelicula_ID` IS NULL;

INSERT INTO `test_results` (`Nombre_Prueba`, `Resultado`, `Detalle`)
SELECT
    'No hay rentas huérfanas (sin cliente válido)',
    IF(COUNT(*) = 0, 'PASS', 'FAIL'),
    CONCAT('Huérfanas: ', COUNT(*))
FROM `renta` r
LEFT JOIN `cliente` c ON c.`Cliente_ID` = r.`Cliente_ID`
WHERE c.`Cliente_ID` IS NULL;

-- ---------------------------------------------------------------------------------
-- PRUEBA 6: el trigger de auto-aval rechaza que un cliente sea avalado por sí mismo.
-- El INSERT siguiente debe fallar (se requiere ejecutar este script con --force para
-- que la conexión continúe después del error esperado).
-- ---------------------------------------------------------------------------------
-- Limpieza previa por si una corrida anterior fue interrumpida antes de su propia
-- limpieza y dejó este registro de prueba a medio insertar.
DELETE FROM `cliente` WHERE `Cliente_ID` = 999001;

INSERT INTO `cliente` (`Cliente_ID`, `Dni`, `Nombre`, `Direccion`, `Telefono`, `Aval_Cliente_ID`)
VALUES (999001, 'TEST-AVAL-001', 'Cliente Prueba Aval', 'Dirección de prueba', '0000000000', 999001);

INSERT INTO `test_results` (`Nombre_Prueba`, `Resultado`, `Detalle`)
SELECT
    'Trigger: un cliente no puede ser su propio aval',
    IF(COUNT(*) = 0, 'PASS', 'FAIL'),
    IF(COUNT(*) = 0, 'El INSERT fue rechazado correctamente', 'El INSERT no fue rechazado')
FROM `cliente` WHERE `Cliente_ID` = 999001;

-- Limpieza defensiva por si el trigger tuviera un error y el registro se llegó a crear.
DELETE FROM `cliente` WHERE `Cliente_ID` = 999001;

-- ---------------------------------------------------------------------------------
-- PRUEBA 7: el trigger de máximo 4 ejemplares activos rechaza el quinto préstamo
-- simultáneo de un mismo cliente. Usa los primeros 5 ejemplares existentes.
-- ---------------------------------------------------------------------------------
-- Limpieza previa por si una corrida anterior fue interrumpida antes de su propia
-- limpieza (evita que el INSERT falle por Dni duplicado en vez de probar el trigger).
DELETE er FROM `ejemplar_renta` er
INNER JOIN `renta` r ON r.`Renta_ID` = er.`Renta_ID`
INNER JOIN `cliente` c ON c.`Cliente_ID` = r.`Cliente_ID`
WHERE c.`Dni` = 'TEST-MAX4-001';
DELETE r FROM `renta` r
INNER JOIN `cliente` c ON c.`Cliente_ID` = r.`Cliente_ID`
WHERE c.`Dni` = 'TEST-MAX4-001';
DELETE FROM `cliente` WHERE `Dni` = 'TEST-MAX4-001';

INSERT INTO `cliente` (`Dni`, `Nombre`, `Direccion`, `Telefono`, `Aval_Cliente_ID`)
VALUES ('TEST-MAX4-001', 'Cliente Prueba Max4', 'Dirección de prueba', '0000000000', NULL);
SET @cliente_max4 = LAST_INSERT_ID();

INSERT INTO `renta` (`Cliente_ID`, `Inicia`) VALUES (@cliente_max4, CURDATE());
SET @renta_max4 = LAST_INSERT_ID();

INSERT INTO `ejemplar_renta` (`Renta_ID`, `Ejemplar_ID`)
SELECT @renta_max4, `Ejemplar_ID` FROM `ejemplar` ORDER BY `Ejemplar_ID` LIMIT 1 OFFSET 0;
INSERT INTO `ejemplar_renta` (`Renta_ID`, `Ejemplar_ID`)
SELECT @renta_max4, `Ejemplar_ID` FROM `ejemplar` ORDER BY `Ejemplar_ID` LIMIT 1 OFFSET 1;
INSERT INTO `ejemplar_renta` (`Renta_ID`, `Ejemplar_ID`)
SELECT @renta_max4, `Ejemplar_ID` FROM `ejemplar` ORDER BY `Ejemplar_ID` LIMIT 1 OFFSET 2;
INSERT INTO `ejemplar_renta` (`Renta_ID`, `Ejemplar_ID`)
SELECT @renta_max4, `Ejemplar_ID` FROM `ejemplar` ORDER BY `Ejemplar_ID` LIMIT 1 OFFSET 3;
-- El quinto préstamo activo para el mismo cliente debe ser rechazado por el trigger.
INSERT INTO `ejemplar_renta` (`Renta_ID`, `Ejemplar_ID`)
SELECT @renta_max4, `Ejemplar_ID` FROM `ejemplar` ORDER BY `Ejemplar_ID` LIMIT 1 OFFSET 4;

INSERT INTO `test_results` (`Nombre_Prueba`, `Resultado`, `Detalle`)
SELECT
    'Trigger: máximo 4 ejemplares activos por socio',
    IF(COUNT(*) = 4, 'PASS', 'FAIL'),
    CONCAT('Ejemplares activos registrados: ', COUNT(*), ' (se esperaban 4)')
FROM `ejemplar_renta` WHERE `Renta_ID` = @renta_max4;

-- Limpieza de los datos generados por esta prueba.
DELETE FROM `ejemplar_renta` WHERE `Renta_ID` = @renta_max4;
DELETE FROM `renta` WHERE `Renta_ID` = @renta_max4;
DELETE FROM `cliente` WHERE `Cliente_ID` = @cliente_max4;

-- ---------------------------------------------------------------------------------
-- PRUEBA 8: la restricción CHECK de renta rechaza una fecha de devolución anterior
-- a la fecha de inicio del alquiler.
-- ---------------------------------------------------------------------------------
-- Limpieza previa por si una corrida anterior fue interrumpida antes de su propia
-- limpieza y dejó este registro de prueba a medio insertar.
DELETE FROM `renta` WHERE `Inicia` = '2024-06-10' AND `Termina` = '2024-06-01';

INSERT INTO `renta` (`Cliente_ID`, `Inicia`, `Termina`)
SELECT `Cliente_ID`, '2024-06-10', '2024-06-01' FROM `cliente` ORDER BY `Cliente_ID` LIMIT 1;

INSERT INTO `test_results` (`Nombre_Prueba`, `Resultado`, `Detalle`)
SELECT
    'CHECK: Termina no puede ser anterior a Inicia',
    IF(COUNT(*) = 0, 'PASS', 'FAIL'),
    IF(COUNT(*) = 0, 'El INSERT fue rechazado correctamente', 'El INSERT no fue rechazado')
FROM `renta` WHERE `Inicia` = '2024-06-10' AND `Termina` = '2024-06-01';

-- Limpieza defensiva por si el CHECK tuviera un error y el registro se llegó a crear.
DELETE FROM `renta` WHERE `Inicia` = '2024-06-10' AND `Termina` = '2024-06-01';

-- ---------------------------------------------------------------------------------
-- PRUEBA 9: las vistas devuelven datos consistentes con las tablas base.
-- ---------------------------------------------------------------------------------
INSERT INTO `test_results` (`Nombre_Prueba`, `Resultado`, `Detalle`)
SELECT
    'La vista v_ejemplares_detalle devuelve el mismo total que ejemplar',
    IF((SELECT COUNT(*) FROM `v_ejemplares_detalle`) = (SELECT COUNT(*) FROM `ejemplar`), 'PASS', 'FAIL'),
    CONCAT('Vista: ', (SELECT COUNT(*) FROM `v_ejemplares_detalle`), ' / Tabla: ', (SELECT COUNT(*) FROM `ejemplar`));

INSERT INTO `test_results` (`Nombre_Prueba`, `Resultado`, `Detalle`)
SELECT
    'La vista v_clientes_con_aval devuelve el mismo total que cliente',
    IF((SELECT COUNT(*) FROM `v_clientes_con_aval`) = (SELECT COUNT(*) FROM `cliente`), 'PASS', 'FAIL'),
    CONCAT('Vista: ', (SELECT COUNT(*) FROM `v_clientes_con_aval`), ' / Tabla: ', (SELECT COUNT(*) FROM `cliente`));

-- ---------------------------------------------------------------------------------
-- PRUEBA 10: los usuarios creados en 05_DCL.sql existen con los permisos esperados.
-- ---------------------------------------------------------------------------------
INSERT INTO `test_results` (`Nombre_Prueba`, `Resultado`, `Detalle`)
SELECT
    'Usuario glob_gusters_reportes tiene sólo permiso SELECT',
    IF(
        SUM(`PRIVILEGE_TYPE` = 'SELECT') = 1 AND SUM(`PRIVILEGE_TYPE` IN ('INSERT', 'UPDATE', 'DELETE')) = 0,
        'PASS', 'FAIL'
    ),
    CONCAT('Privilegios encontrados: ', GROUP_CONCAT(`PRIVILEGE_TYPE` SEPARATOR ', '))
FROM `information_schema`.`SCHEMA_PRIVILEGES`
WHERE `GRANTEE` = "'glob_gusters_reportes'@'localhost'" AND `TABLE_SCHEMA` = 'glob_gusters';

INSERT INTO `test_results` (`Nombre_Prueba`, `Resultado`, `Detalle`)
SELECT
    'Usuario glob_gusters_mostrador no tiene permiso DELETE',
    IF(SUM(`PRIVILEGE_TYPE` = 'DELETE') = 0, 'PASS', 'FAIL'),
    CONCAT('Privilegios encontrados: ', GROUP_CONCAT(`PRIVILEGE_TYPE` SEPARATOR ', '))
FROM `information_schema`.`SCHEMA_PRIVILEGES`
WHERE `GRANTEE` = "'glob_gusters_mostrador'@'localhost'" AND `TABLE_SCHEMA` = 'glob_gusters';

-- ---------------------------------------------------------------------------------
-- RESULTADO: detalle de cada prueba y resumen final de aprobadas/fallidas.
-- ---------------------------------------------------------------------------------
SELECT * FROM `test_results` ORDER BY `Test_ID`;

SELECT
    COUNT(*)                                                        AS Total_Pruebas,
    SUM(`Resultado` = 'PASS')                                       AS Aprobadas,
    SUM(`Resultado` = 'FAIL')                                       AS Fallidas,
    IF(SUM(`Resultado` = 'FAIL') = 0, 'PROYECTO OK', 'REVISAR FALLAS') AS Veredicto
FROM `test_results`;

DROP TEMPORARY TABLE `test_results`;
