-- =====================================================================================
-- 04_VDL.sql - View Definition Language (Oracle APEX)
-- Autor: Andrés Felipe Gutiérrez Rivera
--
-- REQUISITOS:
--   * Oracle Database 12c o superior (columnas IDENTITY), o un workspace de Oracle APEX
--     (SQL Workshop > SQL Scripts). No requiere instalar nada más en el equipo; con
--     SQL*Plus o SQLcl se ejecuta con `@ruta/archivo.sql` en cualquier sistema operativo.
--     Orden de ejecución y detalles: README.md, sección «Versión para Oracle APEX».
--
-- Objetivo: definir y administrar vistas sobre la estructura y datos ya cargados.
-- Incluye: CREATE OR REPLACE VIEW, consulta de las vistas y DROP VIEW de ejemplo.
--
-- ORDEN DE EJECUCIÓN: después de 03_DQL_oracle.sql.
--
-- EJECUCIÓN SEGURA / IDEMPOTENCIA:
--   CREATE OR REPLACE VIEW redefine la vista sin error si ya existe. Los SELECT son
--   de sólo lectura. Oracle (anterior a 23ai) no admite DROP VIEW IF EXISTS, por lo
--   que los DROP se dejan comentados.
-- =====================================================================================

-- ---------------------------------------------------------------------------------
-- CREATE VIEW: combina pelicula + ejemplar + estado en una vista de consulta.
-- ---------------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_ejemplares_detalle AS
SELECT
    e.ejemplar_id,
    e.numero    AS numero_ejemplar,
    p.titulo    AS pelicula,
    p.anio,
    es.nombre   AS estado_conservacion
FROM ejemplar e
INNER JOIN pelicula p ON p.pelicula_id = e.pelicula_id
INNER JOIN estado es  ON es.estado_id = e.estado_id;

-- Consulta de la vista, igual que si fuera una tabla.
SELECT * FROM v_ejemplares_detalle ORDER BY pelicula, numero_ejemplar;

-- ---------------------------------------------------------------------------------
-- CREATE VIEW: socios junto con el nombre de quien los avala.
-- ---------------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_clientes_con_aval AS
SELECT
    c.cliente_id,
    c.nombre    AS cliente,
    c.dni,
    aval.nombre AS avalado_por
FROM cliente c
LEFT JOIN cliente aval ON aval.cliente_id = c.aval_cliente_id;

-- Consulta de verificación de la segunda vista.
SELECT * FROM v_clientes_con_aval ORDER BY cliente;

-- ---------------------------------------------------------------------------------
-- DROP VIEW: ejemplo de eliminación de vistas. Se deja comentado para no borrar las
-- vistas recién creadas.
-- ---------------------------------------------------------------------------------
-- DROP VIEW v_ejemplares_detalle;
-- DROP VIEW v_clientes_con_aval;
