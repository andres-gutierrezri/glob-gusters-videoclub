-- =====================================================================================
-- 01_DDL.sql — Data Definition Language
-- Objetivo: definir y modificar la estructura de la base de datos Glob-Gusters.
-- Incluye: CREATE, ALTER (agregar/modificar columnas) y DROP (eliminar tabla de prueba).
--
-- REQUISITOS:
--   * Servidor MariaDB 10.2.1 o superior (verificado con 10.4.28, el de XAMPP). No está
--     pensado para MySQL de Oracle: usa sintaxis propia de MariaDB (IF NOT EXISTS en
--     ADD COLUMN / CREATE INDEX / CREATE TRIGGER, CHECK y CREATE OR REPLACE VIEW).
--   * Cliente `mariadb` (o `mysql`) en la terminal. Instalación y comandos por sistema
--     operativo (Windows, macOS y Linux): README.md, secciones «Dependencias requeridas»
--     y «Guía de ejecución por sistema operativo».
--
-- CÓMO SE EJECUTA:
--   Debe correrse DESPUÉS de sql/mariadb/glob_gusters.sql (las tablas base ya deben
--   existir) y ANTES de 02_DML.sql, porque aquí se agregan columnas que los scripts
--   siguientes van a utilizar.
--
-- EJECUCIÓN SEGURA / IDEMPOTENCIA:
--   Todas las sentencias usan IF [NOT] EXISTS (CREATE TABLE, ADD COLUMN, CREATE INDEX,
--   DROP TABLE), por lo que este script puede ejecutarse varias veces seguidas sin
--   error: si la columna, el índice o la tabla ya existen, la sentencia simplemente no
--   hace nada en vez de fallar.
-- =====================================================================================

-- Codificación: SET NAMES fija utf8mb4 en la sesión para que las tildes y la ñ se lean y se
-- impriman bien aunque el cliente no se haya lanzado con --default-character-set=utf8mb4.
SET NAMES utf8mb4;

-- Selecciona el esquema del proyecto como base de datos activa.
USE `glob_gusters`;

-- ---------------------------------------------------------------------------------
-- CREATE: crea una tabla nueva de prueba para demostrar el comando CREATE TABLE.
-- Se usa para validar que el esquema y los permisos funcionan antes de tocar las
-- tablas reales del modelo.
-- ---------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `tabla_prueba` (
    -- Llave primaria autoincremental, sigue la misma convención del resto del modelo.
    `Tabla_Prueba_ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    -- Campo de texto simple usado únicamente para la prueba.
    `Descripcion` VARCHAR(100) NOT NULL,
    PRIMARY KEY (`Tabla_Prueba_ID`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci
  COMMENT = 'Tabla temporal usada únicamente para demostrar sentencias DDL.';

-- ---------------------------------------------------------------------------------
-- ALTER: agrega una columna nueva a la tabla `cliente` para registrar el correo
-- electrónico del socio (dato que no estaba contemplado en el modelo original).
-- ---------------------------------------------------------------------------------
ALTER TABLE `cliente`
    ADD COLUMN IF NOT EXISTS `Email` VARCHAR(120) NULL
    COMMENT 'Correo electrónico de contacto del socio (opcional).';

-- ---------------------------------------------------------------------------------
-- ALTER: agrega una columna a `pelicula` para registrar la duración en minutos.
-- ---------------------------------------------------------------------------------
ALTER TABLE `pelicula`
    ADD COLUMN IF NOT EXISTS `Duracion_Minutos` SMALLINT UNSIGNED NULL
    COMMENT 'Duración de la película en minutos.';

-- ---------------------------------------------------------------------------------
-- ALTER: modifica el tamaño máximo del campo `Telefono` de `cliente`, ya que
-- 20 caracteres se quedaban cortos para números con indicativo internacional.
-- ---------------------------------------------------------------------------------
ALTER TABLE `cliente`
    MODIFY COLUMN `Telefono` VARCHAR(25) NOT NULL
    COMMENT 'Teléfono de contacto del socio, incluye indicativo internacional.';

-- ---------------------------------------------------------------------------------
-- CREATE INDEX: crea un índice sobre `pelicula.Titulo` para acelerar las búsquedas
-- de películas por título, operación muy frecuente en el negocio.
-- ---------------------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS `idx_pelicula_titulo` ON `pelicula` (`Titulo`);

-- ---------------------------------------------------------------------------------
-- DROP: elimina la tabla de prueba creada al inicio del script, ya que sólo servía
-- para demostrar el comando CREATE TABLE y no forma parte del modelo final.
-- ---------------------------------------------------------------------------------
DROP TABLE IF EXISTS `tabla_prueba`;
