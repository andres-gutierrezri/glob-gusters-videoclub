-- =====================================================================================
-- 05_DCL.sql - Data Control Language (Oracle APEX)
-- Autor: Andrés Felipe Gutiérrez Rivera
--
-- REQUISITOS:
--   * Oracle Database 12c o superior (columnas IDENTITY), o un workspace de Oracle APEX
--     (SQL Workshop > SQL Scripts). No requiere instalar nada más en el equipo; con
--     SQL*Plus o SQLcl se ejecuta con `@ruta/archivo.sql` en cualquier sistema operativo.
--     Orden de ejecución y detalles: README.md, sección «Versión para Oracle APEX».
--
-- Objetivo: gestionar permisos y accesos a la base de datos Glob-Gusters.
-- Incluye: creación de usuarios, GRANT de lectura/escritura, REVOKE de borrado y
-- consulta de privilegios otorgados.
--
-- ORDEN DE EJECUCIÓN: después de 04_VDL_oracle.sql.
--
-- IMPORTANTE (Oracle):
--   * CREATE USER y GRANT CREATE SESSION requieren privilegios administrativos que un
--     esquema de workspace de APEX normalmente NO tiene. Si faltan, el script no
--     falla: informa el motivo con DBMS_OUTPUT y continúa. Para crear los usuarios
--     ejecute este script con un usuario administrador (p. ej. ADMIN en Autonomous
--     Database, o SQL Developer Web / Database Actions).
--   * Oracle no tiene "GRANT ... ON esquema.*": los privilegios se otorgan objeto por
--     objeto, por lo que se recorren las tablas y vistas del modelo.
--   * FLUSH PRIVILEGES no existe en Oracle: los privilegios se aplican de inmediato.
--   * Cambie las contraseñas por valores propios antes de usar en producción.
--
-- EJECUCIÓN SEGURA / IDEMPOTENCIA:
--   Los usuarios sólo se crean si no existen; los GRANT repetidos no generan error; el
--   REVOKE sólo se ejecuta si el privilegio DELETE realmente fue otorgado (en Oracle,
--   revocar un privilegio no otorgado lanza ORA-01927).
-- =====================================================================================

DECLARE
    c_reportes  CONSTANT VARCHAR2(30) := 'GLOB_GUSTERS_REPORTES';
    c_mostrador CONSTANT VARCHAR2(30) := 'GLOB_GUSTERS_MOSTRADOR';

    -- Ejecuta una sentencia DDL/DCL; si falta algún privilegio administrativo o el
    -- usuario destino no existe, lo informa y continúa en lugar de abortar el script.
    PROCEDURE ejecutar (p_sql IN VARCHAR2) IS
    BEGIN
        EXECUTE IMMEDIATE p_sql;
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE IN (-1031, -1917, -1918) THEN
                DBMS_OUTPUT.PUT_LINE('Omitido (privilegios insuficientes o usuario inexistente): ' || p_sql);
            ELSE
                RAISE;
            END IF;
    END ejecutar;

    FUNCTION existe_usuario (p_usuario IN VARCHAR2) RETURN BOOLEAN IS
        v_n NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_n FROM all_users WHERE username = p_usuario;
        RETURN v_n > 0;
    END existe_usuario;
BEGIN
    -- CREATE USER: usuario de sólo lectura para reportes.
    IF NOT existe_usuario(c_reportes) THEN
        ejecutar('CREATE USER ' || c_reportes || ' IDENTIFIED BY "Reportes#2024"');
        ejecutar('GRANT CREATE SESSION TO ' || c_reportes);
    END IF;

    -- CREATE USER: usuario operativo para el mostrador del video-club.
    IF NOT existe_usuario(c_mostrador) THEN
        ejecutar('CREATE USER ' || c_mostrador || ' IDENTIFIED BY "Mostrador#2024"');
        ejecutar('GRANT CREATE SESSION TO ' || c_mostrador);
    END IF;

    -- GRANT / REVOKE sobre los objetos del modelo (sólo si el usuario existe).
    FOR o IN (SELECT object_name, object_type
                FROM user_objects
               WHERE object_type IN ('TABLE', 'VIEW')
                 AND object_name IN ('NACIONALIDAD', 'PRODUCTORA', 'ESTADO', 'DIRECTOR',
                                     'PELICULA', 'ACTOR', 'REPARTO', 'CLIENTE', 'EJEMPLAR',
                                     'RENTA', 'EJEMPLAR_RENTA',
                                     'V_EJEMPLARES_DETALLE', 'V_CLIENTES_CON_AVAL'))
    LOOP
        -- Reportes: sólo lectura sobre tablas y vistas.
        IF existe_usuario(c_reportes) THEN
            ejecutar('GRANT SELECT ON ' || o.object_name || ' TO ' || c_reportes);
        END IF;

        IF existe_usuario(c_mostrador) THEN
            -- Mostrador: lectura sobre tablas y vistas; inserción y actualización sólo en tablas.
            ejecutar('GRANT SELECT ON ' || o.object_name || ' TO ' || c_mostrador);
            IF o.object_type = 'TABLE' THEN
                ejecutar('GRANT INSERT, UPDATE ON ' || o.object_name || ' TO ' || c_mostrador);

                -- REVOKE: retira DELETE solo si estuviera otorgado.
                FOR p IN (SELECT 1
                            FROM user_tab_privs_made
                           WHERE grantee = c_mostrador
                             AND table_name = o.object_name
                             AND privilege = 'DELETE')
                LOOP
                    ejecutar('REVOKE DELETE ON ' || o.object_name || ' FROM ' || c_mostrador);
                END LOOP;
            END IF;
        END IF;
    END LOOP;
END;
/

-- ---------------------------------------------------------------------------------
-- Verificación: privilegios sobre objetos otorgados a cada usuario
-- (equivalente a SHOW GRANTS de MariaDB).
-- ---------------------------------------------------------------------------------
SELECT grantee, table_name, privilege
  FROM user_tab_privs_made
 WHERE grantee IN ('GLOB_GUSTERS_REPORTES', 'GLOB_GUSTERS_MOSTRADOR')
 ORDER BY grantee, table_name, privilege;
