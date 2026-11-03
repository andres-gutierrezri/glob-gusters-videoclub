-- =====================================================================================
-- 02_DML.sql - Data Manipulation Language (Oracle APEX)
-- Autor: Andrés Felipe Gutiérrez Rivera
--
-- Objetivo: manipular los datos ya cargados en la base de datos Glob-Gusters.
-- Incluye: INSERT (nuevo socio), UPDATE (estado de un ejemplar y duración de una
-- película) y DELETE (registro de reparto).
--
-- ORDEN DE EJECUCIÓN: después de glob_gusters_insert_oracle.sql y 01_DDL_oracle.sql
-- (la columna EMAIL de CLIENTE y DURACION_MINUTOS de PELICULA ya deben existir).
--
-- EJECUCIÓN SEGURA / IDEMPOTENCIA:
--   Ninguna sentencia usa IDs fijos: los registros se localizan por llave natural.
--   El INSERT se convirtió a MERGE (sólo inserta si el DNI no existe); los UPDATE y
--   DELETE son naturalmente idempotentes.
-- =====================================================================================

-- ---------------------------------------------------------------------------------
-- INSERT: registra un nuevo socio avalado por Laura Gómez (localizada por DNI),
-- incluyendo el correo agregado en 01_DDL_oracle.sql.
-- ---------------------------------------------------------------------------------
MERGE INTO cliente c
USING (
    SELECT '1000000005' AS dni,
           'Sofía Ramírez' AS nombre,
           'Calle 50 # 20-30' AS direccion,
           '3011122334' AS telefono,
           a.cliente_id AS aval_cliente_id,
           'sofia.ramirez@example.com' AS email
    FROM cliente a
    WHERE a.dni = '1000000001'
) s
ON (c.dni = s.dni)
WHEN NOT MATCHED THEN
    INSERT (dni, nombre, direccion, telefono, aval_cliente_id, email)
    VALUES (s.dni, s.nombre, s.direccion, s.telefono, s.aval_cliente_id, s.email);

-- ---------------------------------------------------------------------------------
-- UPDATE: marca como 'Dañado' el ejemplar número 2 de "Quo Vadis" (1951),
-- identificado por su llave natural (película + número de ejemplar).
-- ---------------------------------------------------------------------------------
UPDATE ejemplar
   SET estado_id = (SELECT estado_id FROM estado WHERE nombre = 'Dañado')
 WHERE numero = 2
   AND pelicula_id = (SELECT pelicula_id FROM pelicula
                       WHERE titulo = 'Quo Vadis' AND anio = 1951);

-- ---------------------------------------------------------------------------------
-- UPDATE: asigna la duración de "Interstellar" (2014), columna agregada en el DDL.
-- ---------------------------------------------------------------------------------
UPDATE pelicula
   SET duracion_minutos = 169
 WHERE titulo = 'Interstellar' AND anio = 2014;

-- ---------------------------------------------------------------------------------
-- DELETE: elimina el reparto de Anne Hathaway en Interstellar (2014), ingresado por
-- error. Repetirlo no afecta ninguna fila ni genera error.
-- ---------------------------------------------------------------------------------
DELETE FROM reparto
 WHERE pelicula_id = (SELECT pelicula_id FROM pelicula
                       WHERE titulo = 'Interstellar' AND anio = 2014)
   AND actor_id = (SELECT actor_id FROM actor WHERE nombre = 'Anne Hathaway');

-- Confirma los cambios realizados.
COMMIT;
