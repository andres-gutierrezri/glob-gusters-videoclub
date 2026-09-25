-- =====================================================================================
-- 01_DDL.sql — Data Definition Language
-- Objetivo: definir y modificar la estructura de la base de datos Glob-Gusters.
-- Incluye: CREATE, ALTER (agregar/modificar columnas) y DROP (eliminar tabla de prueba).
--
-- CÓMO SE EJECUTA:
--   Debe correrse DESPUÉS de sql/mariadb/glob_gusters.sql (las tablas base ya deben
--   existir) y ANTES de 02_DML.sql, porque aquí se agregan columnas que los scripts
--   siguientes van a utilizar.
-- =====================================================================================

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
    ADD COLUMN `Email` VARCHAR(120) NULL
    COMMENT 'Correo electrónico de contacto del socio (opcional).';

-- ---------------------------------------------------------------------------------
-- ALTER: agrega una columna a `pelicula` para registrar la duración en minutos.
-- ---------------------------------------------------------------------------------
ALTER TABLE `pelicula`
    ADD COLUMN `Duracion_Minutos` SMALLINT UNSIGNED NULL
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
CREATE INDEX `idx_pelicula_titulo` ON `pelicula` (`Titulo`);

-- ---------------------------------------------------------------------------------
-- DROP: elimina la tabla de prueba creada al inicio del script, ya que sólo servía
-- para demostrar el comando CREATE TABLE y no forma parte del modelo final.
-- ---------------------------------------------------------------------------------
DROP TABLE IF EXISTS `tabla_prueba`;
