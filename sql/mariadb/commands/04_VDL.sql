-- =====================================================================================
-- 04_VDL.sql — View Definition Language
-- Objetivo: definir y administrar vistas basadas en la estructura y datos ya cargados.
-- Incluye: CREATE VIEW, consulta de la vista y DROP VIEW de ejemplo.
--
-- CÓMO SE EJECUTA:
--   Debe correrse DESPUÉS de 03_DQL.sql, cuando ya se confirmó que los datos base
--   son correctos. Las vistas se apoyan en las tablas pelicula, ejemplar y estado.
--
-- EJECUCIÓN SEGURA / IDEMPOTENCIA:
--   Ambas vistas se definen con CREATE OR REPLACE VIEW, por lo que ejecutarlo varias
--   veces simplemente vuelve a definir la misma vista sin error. Los SELECT son de
--   sólo lectura y el DROP VIEW usa IF EXISTS (queda comentado por defecto).
-- =====================================================================================

USE `glob_gusters`;

-- ---------------------------------------------------------------------------------
-- CREATE VIEW: combina pelicula + ejemplar + estado en una sola vista de consulta,
-- equivalente a la vista de "propiedades con datos de ubicación" del resumen de
-- comandos, adaptada al dominio del video-club.
-- ---------------------------------------------------------------------------------
CREATE OR REPLACE VIEW `v_ejemplares_detalle` AS
SELECT
    e.`Ejemplar_ID`,
    e.`Numero`              AS Numero_Ejemplar,
    p.`Titulo`              AS Pelicula,
    p.`Anio`,
    es.`Nombre`             AS Estado_Conservacion
FROM `ejemplar` e
INNER JOIN `pelicula` p ON p.`Pelicula_ID` = e.`Pelicula_ID`
INNER JOIN `estado` es  ON es.`Estado_ID` = e.`Estado_ID`;

-- ---------------------------------------------------------------------------------
-- SELECT sobre la vista: se consulta exactamente igual que si fuera una tabla.
-- ---------------------------------------------------------------------------------
SELECT * FROM `v_ejemplares_detalle` ORDER BY `Pelicula`, `Numero_Ejemplar`;

-- ---------------------------------------------------------------------------------
-- CREATE VIEW: vista de socios activos junto con el nombre de quien los avala,
-- útil para atención al cliente.
-- ---------------------------------------------------------------------------------
CREATE OR REPLACE VIEW `v_clientes_con_aval` AS
SELECT
    c.`Cliente_ID`,
    c.`Nombre`               AS Cliente,
    c.`Dni`,
    aval.`Nombre`             AS Avalado_Por
FROM `cliente` c
LEFT JOIN `cliente` aval ON aval.`Cliente_ID` = c.`Aval_Cliente_ID`;

-- Consulta de verificación de la segunda vista.
SELECT * FROM `v_clientes_con_aval` ORDER BY `Cliente`;

-- ---------------------------------------------------------------------------------
-- DROP VIEW: ejemplo de cómo eliminar una vista si dejara de ser necesaria.
-- Se deja comentado para no borrar las vistas recién creadas al ejecutar el script.
-- ---------------------------------------------------------------------------------
-- DROP VIEW IF EXISTS `v_ejemplares_detalle`;
-- DROP VIEW IF EXISTS `v_clientes_con_aval`;
