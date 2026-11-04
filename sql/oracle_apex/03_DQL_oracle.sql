-- =====================================================================================
-- 03_DQL.sql - Data Query Language (Oracle APEX)
-- Autor: Andrés Felipe Gutiérrez Rivera
--
-- REQUISITOS:
--   * Oracle Database 12c o superior (columnas IDENTITY), o un workspace de Oracle APEX
--     (SQL Workshop > SQL Scripts). No requiere instalar nada más en el equipo; con
--     SQL*Plus o SQLcl se ejecuta con `@ruta/archivo.sql` en cualquier sistema operativo.
--     Orden de ejecución y detalles: README.md, sección «Versión para Oracle APEX».
--
-- Objetivo: consultar los datos cargados para verificar que todo esté correcto.
-- Incluye: SELECT con condiciones, JOIN entre tablas y GROUP BY con conteos.
--
-- ORDEN DE EJECUCIÓN: después de 02_DML_oracle.sql.
-- EJECUCIÓN SEGURA: todas las sentencias son SELECT de sólo lectura.
-- =====================================================================================

-- ---------------------------------------------------------------------------------
-- SELECT con condición: ejemplares disponibles para alquilar, es decir, los que NO
-- tienen una entrega pendiente (ENTREGA nula) en EJEMPLAR_RENTA.
-- ---------------------------------------------------------------------------------
SELECT
    e.ejemplar_id,
    e.numero,
    p.titulo
FROM ejemplar e
INNER JOIN pelicula p ON p.pelicula_id = e.pelicula_id
WHERE e.ejemplar_id NOT IN (
    SELECT er.ejemplar_id
    FROM ejemplar_renta er
    WHERE er.entrega IS NULL
)
ORDER BY p.titulo, e.numero;

-- ---------------------------------------------------------------------------------
-- JOIN: rentas activas (sin fecha de devolución) combinando cliente + renta +
-- ejemplar + película.
-- ---------------------------------------------------------------------------------
SELECT
    c.nombre    AS cliente,
    r.renta_id,
    r.inicia,
    pe.titulo   AS pelicula,
    ej.numero   AS numero_ejemplar
FROM renta r
INNER JOIN cliente c         ON c.cliente_id = r.cliente_id
INNER JOIN ejemplar_renta er ON er.renta_id = r.renta_id
INNER JOIN ejemplar ej       ON ej.ejemplar_id = er.ejemplar_id
INNER JOIN pelicula pe       ON pe.pelicula_id = ej.pelicula_id
WHERE r.termina IS NULL
ORDER BY r.inicia;

-- ---------------------------------------------------------------------------------
-- GROUP BY: cantidad de películas registradas por nacionalidad.
-- ---------------------------------------------------------------------------------
SELECT
    n.nombre    AS nacionalidad,
    COUNT(*)    AS total_peliculas
FROM pelicula p
INNER JOIN nacionalidad n ON n.nacionalidad_id = p.nacionalidad_id
GROUP BY n.nombre
ORDER BY total_peliculas DESC, n.nombre;

-- ---------------------------------------------------------------------------------
-- GROUP BY adicional: cantidad de ejemplares por estado de conservación.
-- ---------------------------------------------------------------------------------
SELECT
    es.nombre   AS estado,
    COUNT(*)    AS total_ejemplares
FROM ejemplar e
INNER JOIN estado es ON es.estado_id = e.estado_id
GROUP BY es.nombre
ORDER BY es.nombre;
