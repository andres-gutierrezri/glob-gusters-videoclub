-- =====================================================================================
-- 03_DQL.sql — Data Query Language
-- Objetivo: consultar los datos ya cargados para verificar que todo esté correcto.
-- Incluye: SELECT con condiciones, JOIN entre tablas y GROUP BY con conteos.
--
-- CÓMO SE EJECUTA:
--   Debe correrse DESPUÉS de 02_DML.sql, ya que consulta datos y columnas
--   (Email, Duracion_Minutos, Estado_ID actualizado) generados en los scripts previos.
-- =====================================================================================

USE `glob_gusters`;

-- ---------------------------------------------------------------------------------
-- SELECT con condición: lista los ejemplares que están disponibles para alquilar,
-- es decir, aquellos que NO aparecen con Entrega pendiente (NULL) en ejemplar_renta.
-- ---------------------------------------------------------------------------------
SELECT
    e.`Ejemplar_ID`,
    e.`Numero`,
    p.`Titulo`
FROM `ejemplar` e
INNER JOIN `pelicula` p ON p.`Pelicula_ID` = e.`Pelicula_ID`
WHERE e.`Ejemplar_ID` NOT IN (
    SELECT er.`Ejemplar_ID`
    FROM `ejemplar_renta` er
    WHERE er.`Entrega` IS NULL
);

-- ---------------------------------------------------------------------------------
-- JOIN: lista las "visitas programadas" del negocio, en este caso, las rentas que
-- todavía están activas (sin fecha de devolución), combinando cliente + renta +
-- ejemplar + pelicula.
-- ---------------------------------------------------------------------------------
SELECT
    c.`Nombre`      AS Cliente,
    r.`Renta_ID`,
    r.`Inicia`,
    pe.`Titulo`     AS Pelicula,
    ej.`Numero`     AS Numero_Ejemplar
FROM `renta` r
INNER JOIN `cliente` c         ON c.`Cliente_ID` = r.`Cliente_ID`
INNER JOIN `ejemplar_renta` er ON er.`Renta_ID` = r.`Renta_ID`
INNER JOIN `ejemplar` ej       ON ej.`Ejemplar_ID` = er.`Ejemplar_ID`
INNER JOIN `pelicula` pe       ON pe.`Pelicula_ID` = ej.`Pelicula_ID`
WHERE r.`Termina` IS NULL
ORDER BY r.`Inicia`;

-- ---------------------------------------------------------------------------------
-- GROUP BY: cuenta cuántas películas hay registradas por cada nacionalidad,
-- equivalente al "conteo de propiedades agrupadas por tipo" del resumen de comandos.
-- ---------------------------------------------------------------------------------
SELECT
    n.`Nombre`      AS Nacionalidad,
    COUNT(*)        AS Total_Peliculas
FROM `pelicula` p
INNER JOIN `nacionalidad` n ON n.`Nacionalidad_ID` = p.`Nacionalidad_ID`
GROUP BY n.`Nombre`
ORDER BY Total_Peliculas DESC;

-- ---------------------------------------------------------------------------------
-- GROUP BY adicional: cuenta cuántos ejemplares hay por cada estado de conservación,
-- útil para saber cuántas copias requieren mantenimiento o reemplazo.
-- ---------------------------------------------------------------------------------
SELECT
    es.`Nombre`     AS Estado,
    COUNT(*)        AS Total_Ejemplares
FROM `ejemplar` e
INNER JOIN `estado` es ON es.`Estado_ID` = e.`Estado_ID`
GROUP BY es.`Nombre`;
