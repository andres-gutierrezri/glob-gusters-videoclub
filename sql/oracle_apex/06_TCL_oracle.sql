-- =====================================================================================
-- 06_TCL.sql - Transaction Control Language (Oracle APEX)
-- Autor: Andrés Felipe Gutiérrez Rivera
--
-- REQUISITOS:
--   * Oracle Database 12c o superior (columnas IDENTITY), o un workspace de Oracle APEX
--     (SQL Workshop > SQL Scripts). No requiere instalar nada más en el equipo; con
--     SQL*Plus o SQLcl se ejecuta con `@ruta/archivo.sql` en cualquier sistema operativo.
--     Orden de ejecución y detalles: README.md, sección «Versión para Oracle APEX».
--
-- Objetivo: agrupar operaciones relacionadas en transacciones que aseguren la
-- integridad de los datos (COMMIT / ROLLBACK / SAVEPOINT). Ejemplo: registrar una
-- renta junto con el ejemplar que se lleva el cliente.
--
-- ORDEN DE EJECUCIÓN: AL FINAL, después de 05_DCL_oracle.sql.
--
-- DIFERENCIAS CON MARIADB:
--   * Oracle no tiene START TRANSACTION: la transacción se abre implícitamente con la
--     primera sentencia DML y termina con COMMIT o ROLLBACK.
--   * Las variables de sesión (@variable) se sustituyen por variables PL/SQL.
--   * LAST_INSERT_ID() se sustituye por la cláusula RETURNING ... INTO.
--   * CURDATE() se sustituye por TRUNC(SYSDATE).
--
-- EJECUCIÓN SEGURA / IDEMPOTENCIA:
--   Si el cliente de ejemplo ya tiene ese ejemplar prestado sin devolver, no se vuelve
--   a insertar nada (se evita acumular préstamos hasta chocar con el trigger de máximo
--   4 ejemplares). Cliente y ejemplar se localizan por llave natural.
-- =====================================================================================

-- ---------------------------------------------------------------------------------
-- Transacción 1: registra el encabezado de la renta y su detalle de forma atómica.
-- Si algo falla, se hace ROLLBACK y ninguno de los dos cambios queda aplicado.
-- ---------------------------------------------------------------------------------
DECLARE
    v_cliente_id  cliente.cliente_id%TYPE;
    v_ejemplar_id ejemplar.ejemplar_id%TYPE;
    v_renta_id    renta.renta_id%TYPE;
    v_existe      NUMBER;
BEGIN
    -- Cliente de ejemplo: Andrés Torres, localizado por DNI.
    SELECT cliente_id INTO v_cliente_id FROM cliente WHERE dni = '1000000004';

    -- Ejemplar de ejemplo: Interstellar (2014), ejemplar número 2.
    SELECT e.ejemplar_id
      INTO v_ejemplar_id
      FROM ejemplar e
      INNER JOIN pelicula p ON p.pelicula_id = e.pelicula_id
     WHERE p.titulo = 'Interstellar' AND p.anio = 2014 AND e.numero = 2;

    -- ¿El cliente ya tiene este ejemplar prestado sin devolver?
    SELECT COUNT(*)
      INTO v_existe
      FROM ejemplar_renta er
      INNER JOIN renta r ON r.renta_id = er.renta_id
     WHERE r.cliente_id = v_cliente_id
       AND er.ejemplar_id = v_ejemplar_id
       AND er.entrega IS NULL;

    IF v_existe = 0 THEN
        -- Encabezado de la renta; RETURNING recupera el Renta_ID generado.
        INSERT INTO renta (cliente_id, inicia, termina)
        VALUES (v_cliente_id, TRUNC(SYSDATE), NULL)
        RETURNING renta_id INTO v_renta_id;

        -- SAVEPOINT: punto de control tras registrar el encabezado.
        SAVEPOINT sp_renta_creada;

        -- Detalle de la renta (el trigger trg_ejemplar_renta_max_4 valida el máximo de 4).
        INSERT INTO ejemplar_renta (renta_id, ejemplar_id, entrega)
        VALUES (v_renta_id, v_ejemplar_id, NULL);

        -- Ejemplo (comentado): si el detalle violara la regla de los 4 ejemplares,
        -- se podría deshacer sólo el detalle y conservar el encabezado con:
        -- ROLLBACK TO SAVEPOINT sp_renta_creada;
    END IF;

    -- COMMIT: confirma encabezado y detalle (o no confirma nada nuevo si ya existían).
    COMMIT;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20010,
            'No se encontró el cliente o el ejemplar de ejemplo. Ejecute antes los scripts de carga de datos.');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/

-- ---------------------------------------------------------------------------------
-- Transacción 2: cambio que se descarta por completo con ROLLBACK, para demostrar
-- cómo se deshacen cambios no confirmados. No deja ningún efecto persistente.
-- ---------------------------------------------------------------------------------
UPDATE cliente
   SET direccion = 'Dirección temporal de prueba'
 WHERE dni = '1000000001';

-- ROLLBACK: la dirección de Laura Gómez vuelve a su valor anterior.
ROLLBACK;
