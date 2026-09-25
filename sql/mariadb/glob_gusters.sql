-- =====================================================================================
-- Base de Datos Relacional Glob-Gusters Video-Club
-- Autor: Andrés Felipe Gutiérrez Rivera
-- Fecha: 2024-06-10
-- Motor: MariaDB (XAMPP)
--
-- Este script contiene la definición completa (DDL) del modelo normalizado hasta
-- Tercera Forma Normal (3FN) del ejercicio "Video-Clubs Glob-Gusters", basado en el
-- taller resuelto en docs/relational-database.pdf.
--
-- Reglas de normalización aplicadas:
--   1FN: todos los atributos son atómicos (no se admiten campos multivaluados; los
--        campos originalmente multivaluados -Nacionalidad, Productora, Estado- se
--        extrajeron como entidades propias).
--   2FN: no existen dependencias parciales; toda tabla con llave primaria compuesta
--        (reparto, ejemplar_renta) fue sustituida por una llave subrogada
--        autoincremental, dejando la combinación original como llave candidata
--        (restricción UNIQUE) para no perder la regla de negocio.
--   3FN: no existen dependencias transitivas; los atributos no clave de cada tabla
--        dependen únicamente de su llave primaria (p.e. la nacionalidad de un actor
--        no depende del actor sino de la entidad NACIONALIDAD referenciada por FK).
-- =====================================================================================

-- Crea la base de datos si no existe, con soporte completo para UTF-8 (emojis incluidos).
CREATE DATABASE IF NOT EXISTS `glob_gusters` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

-- Elimina la base de datos completa; se deja comentado como medida de seguridad.
-- DROP DATABASE IF EXISTS `glob_gusters`;

-- Selecciona la base de datos como esquema activo para el resto de sentencias del script.
USE `glob_gusters`;

-- =====================================================================================
-- BLOQUE DE COMENTARIOS: DIAGRAMA DE RELACIONES DE LA BASE DE DATOS
-- =====================================================================================
-- +--------------------+-------------------+--------------------+---------------+---------------+--------------------------------------------------+
-- | Tabla Origen (FK)  | Campo FK          | Tabla Destino (PK) | Campo PK      | Cardinalidad  | Descripción                                      |
-- +--------------------+-------------------+--------------------+---------------+---------------+--------------------------------------------------+
-- | director           | Nacionalidad_ID   | nacionalidad       | Nacionalidad_ID | 1-N (N a 1)  | Un director tiene una nacionalidad.               |
-- | actor              | Nacionalidad_ID   | nacionalidad       | Nacionalidad_ID | 1-N (N a 1)  | Un actor tiene una nacionalidad.                  |
-- | pelicula           | Nacionalidad_ID   | nacionalidad       | Nacionalidad_ID | 1-N (N a 1)  | Una película tiene una nacionalidad.              |
-- | pelicula           | Productora_ID     | productora         | Productora_ID | 1-N (N a 1)   | Una película pertenece a una productora.          |
-- | pelicula           | Director_ID       | director           | Director_ID   | 1-N (N a 1)   | Una película es dirigida por un director.         |
-- | ejemplar           | Estado_ID         | estado             | Estado_ID     | 1-N (N a 1)   | Un ejemplar tiene un estado de conservación.      |
-- | ejemplar           | Pelicula_ID       | pelicula           | Pelicula_ID   | 1-N (N a 1)   | Un ejemplar pertenece a una película.             |
-- | reparto             | Pelicula_ID      | pelicula           | Pelicula_ID   | N-M (vía reparto) | Resuelve M-M entre película y actor.          |
-- | reparto             | Actor_ID         | actor              | Actor_ID      | N-M (vía reparto) | Resuelve M-M entre película y actor.          |
-- | cliente             | Aval_Cliente_ID  | cliente            | Cliente_ID    | 1-N (autorreferencia) | Un socio es avalado por otro socio.       |
-- | renta               | Cliente_ID       | cliente            | Cliente_ID    | 1-N (N a 1)   | Una renta es solicitada por un cliente.           |
-- | ejemplar_renta       | Renta_ID         | renta              | Renta_ID      | N-M (vía ejemplar_renta) | Resuelve M-M entre renta y ejemplar.   |
-- | ejemplar_renta       | Ejemplar_ID      | ejemplar           | Ejemplar_ID   | N-M (vía ejemplar_renta) | Resuelve M-M entre renta y ejemplar.   |
-- +--------------------+-------------------+--------------------+---------------+---------------+--------------------------------------------------+

-- =====================================================================================
-- TABLA: nacionalidad
-- Catálogo que evita repetir el nombre del país como texto libre (elimina el campo
-- multivaluado "nacionalidad" de actor/director/pelicula, exigido por la 1FN).
-- =====================================================================================
CREATE TABLE IF NOT EXISTS `nacionalidad` (
    -- Llave primaria autoincremental; el nombre coincide con el de la tabla.
    `Nacionalidad_ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    -- Nombre del país; se restringe como único para no duplicar catálogos.
    `Nombre` VARCHAR(60) NOT NULL,
    -- Declara la llave primaria de la tabla.
    PRIMARY KEY (`Nacionalidad_ID`),
    -- Evita registrar dos veces la misma nacionalidad.
    CONSTRAINT `uq_nacionalidad_nombre` UNIQUE (`Nombre`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci
  COMMENT = 'Catálogo de nacionalidades usado por actor, director y pelicula.';

-- =====================================================================================
-- TABLA: productora
-- Catálogo de casas productoras (campo multivaluado "productora" extraído de pelicula).
-- =====================================================================================
CREATE TABLE IF NOT EXISTS `productora` (
    `Productora_ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `Nombre` VARCHAR(100) NOT NULL,
    PRIMARY KEY (`Productora_ID`),
    CONSTRAINT `uq_productora_nombre` UNIQUE (`Nombre`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci
  COMMENT = 'Catálogo de productoras cinematográficas.';

-- =====================================================================================
-- TABLA: estado
-- Catálogo del estado de conservación de un ejemplar (campo multivaluado extraído
-- de ejemplar).
-- =====================================================================================
CREATE TABLE IF NOT EXISTS `estado` (
    `Estado_ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    -- Ej.: Nuevo, Bueno, Regular, Dañado.
    `Nombre` VARCHAR(30) NOT NULL,
    PRIMARY KEY (`Estado_ID`),
    CONSTRAINT `uq_estado_nombre` UNIQUE (`Nombre`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci
  COMMENT = 'Catálogo de estados de conservación de los ejemplares.';

-- =====================================================================================
-- TABLA: director
-- =====================================================================================
CREATE TABLE IF NOT EXISTS `director` (
    `Director_ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `Nombre` VARCHAR(100) NOT NULL,
    -- Llave foránea hacia el catálogo de nacionalidades.
    `Nacionalidad_ID` INT UNSIGNED NOT NULL,
    PRIMARY KEY (`Director_ID`),
    -- Restringe la nacionalidad a un valor existente en el catálogo.
    CONSTRAINT `fk_director_nacionalidad`
        FOREIGN KEY (`Nacionalidad_ID`) REFERENCES `nacionalidad` (`Nacionalidad_ID`)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci
  COMMENT = 'Directores de las películas del catálogo.';

-- =====================================================================================
-- TABLA: pelicula
-- =====================================================================================
CREATE TABLE IF NOT EXISTS `pelicula` (
    `Pelicula_ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `Titulo` VARCHAR(150) NOT NULL,
    -- Año de estreno; se usa YEAR porque el enunciado sólo exige el año (p.e. 1955).
    `Anio` YEAR NOT NULL,
    `Nacionalidad_ID` INT UNSIGNED NOT NULL,
    `Productora_ID` INT UNSIGNED NOT NULL,
    `Director_ID` INT UNSIGNED NOT NULL,
    PRIMARY KEY (`Pelicula_ID`),
    -- Evita registrar dos veces la misma película en el mismo año.
    CONSTRAINT `uq_pelicula_titulo_anio` UNIQUE (`Titulo`, `Anio`),
    CONSTRAINT `fk_pelicula_nacionalidad`
        FOREIGN KEY (`Nacionalidad_ID`) REFERENCES `nacionalidad` (`Nacionalidad_ID`)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT `fk_pelicula_productora`
        FOREIGN KEY (`Productora_ID`) REFERENCES `productora` (`Productora_ID`)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT `fk_pelicula_director`
        FOREIGN KEY (`Director_ID`) REFERENCES `director` (`Director_ID`)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci
  COMMENT = 'Catálogo de películas ofrecidas en alquiler.';

-- =====================================================================================
-- TABLA: actor
-- =====================================================================================
CREATE TABLE IF NOT EXISTS `actor` (
    `Actor_ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `Nombre` VARCHAR(100) NOT NULL,
    `Nacionalidad_ID` INT UNSIGNED NOT NULL,
    -- Sexo queda como atributo simple (M/F), no requiere entidad propia.
    `Sexo` ENUM('M', 'F') NOT NULL,
    PRIMARY KEY (`Actor_ID`),
    CONSTRAINT `fk_actor_nacionalidad`
        FOREIGN KEY (`Nacionalidad_ID`) REFERENCES `nacionalidad` (`Nacionalidad_ID`)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci
  COMMENT = 'Actores que participan en las películas del catálogo.';

-- =====================================================================================
-- TABLA: reparto
-- Resuelve la relación N-M "una película tiene varios actores / un actor participa en
-- varias películas". La llave primaria es subrogada (autoincremental) por requisito
-- del ejercicio; la combinación original de llaves de los padres se conserva como
-- restricción UNIQUE para no perder la regla de negocio "un actor no puede repetirse
-- en el reparto de la misma película".
-- =====================================================================================
CREATE TABLE IF NOT EXISTS `reparto` (
    `Reparto_ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `Pelicula_ID` INT UNSIGNED NOT NULL,
    `Actor_ID` INT UNSIGNED NOT NULL,
    -- Rol que desempeña el actor dentro de la película.
    `Rol` ENUM('Principal', 'Secundario') NOT NULL,
    PRIMARY KEY (`Reparto_ID`),
    CONSTRAINT `uq_reparto_pelicula_actor` UNIQUE (`Pelicula_ID`, `Actor_ID`),
    CONSTRAINT `fk_reparto_pelicula`
        FOREIGN KEY (`Pelicula_ID`) REFERENCES `pelicula` (`Pelicula_ID`)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT `fk_reparto_actor`
        FOREIGN KEY (`Actor_ID`) REFERENCES `actor` (`Actor_ID`)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci
  COMMENT = 'Entidad intermedia que resuelve la relación N-M entre pelicula y actor.';

-- =====================================================================================
-- TABLA: cliente
-- El "aval" del enunciado ("un socio tiene que ser avalado por otro socio") se modela
-- como una autorreferencia opcional (NULL permitido para el primer socio registrado).
-- =====================================================================================
CREATE TABLE IF NOT EXISTS `cliente` (
    `Cliente_ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    -- Documento de identidad; se conserva único aunque ya no sea la llave primaria.
    `Dni` VARCHAR(15) NOT NULL,
    `Nombre` VARCHAR(100) NOT NULL,
    `Direccion` VARCHAR(150) NOT NULL,
    `Telefono` VARCHAR(20) NOT NULL,
    -- Socio que responde por este cliente; NULL sólo se admite para el primer socio.
    `Aval_Cliente_ID` INT UNSIGNED NULL,
    PRIMARY KEY (`Cliente_ID`),
    CONSTRAINT `uq_cliente_dni` UNIQUE (`Dni`),
    -- Autorreferencia: el aval debe ser otro cliente ya existente.
    CONSTRAINT `fk_cliente_aval`
        FOREIGN KEY (`Aval_Cliente_ID`) REFERENCES `cliente` (`Cliente_ID`)
        ON UPDATE CASCADE ON DELETE RESTRICT
    -- Nota: la regla "un cliente no puede avalarse a sí mismo" no se puede expresar
    -- como CHECK porque MariaDB prohíbe referenciar una columna AUTO_INCREMENT
    -- (Cliente_ID) dentro de una cláusula CHECK; se aplica mediante el trigger
    -- trg_cliente_aval_diferente definido más abajo.
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci
  COMMENT = 'Socios del video-club.';

-- =====================================================================================
-- TABLA: ejemplar
-- =====================================================================================
CREATE TABLE IF NOT EXISTS `ejemplar` (
    `Ejemplar_ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    -- Número de ejemplar dentro de la misma película (1, 2, 3...).
    `Numero` INT UNSIGNED NOT NULL,
    `Pelicula_ID` INT UNSIGNED NOT NULL,
    `Estado_ID` INT UNSIGNED NOT NULL,
    PRIMARY KEY (`Ejemplar_ID`),
    -- El número de ejemplar sólo debe ser único dentro de la misma película.
    CONSTRAINT `uq_ejemplar_pelicula_numero` UNIQUE (`Pelicula_ID`, `Numero`),
    CONSTRAINT `fk_ejemplar_pelicula`
        FOREIGN KEY (`Pelicula_ID`) REFERENCES `pelicula` (`Pelicula_ID`)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT `fk_ejemplar_estado`
        FOREIGN KEY (`Estado_ID`) REFERENCES `estado` (`Estado_ID`)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci
  COMMENT = 'Copias físicas disponibles de cada película.';

-- =====================================================================================
-- TABLA: renta
-- =====================================================================================
CREATE TABLE IF NOT EXISTS `renta` (
    `Renta_ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `Cliente_ID` INT UNSIGNED NOT NULL,
    -- Fecha en que inicia el alquiler.
    `Inicia` DATE NOT NULL,
    -- Fecha real de devolución; NULL mientras el alquiler sigue activo.
    `Termina` DATE NULL,
    PRIMARY KEY (`Renta_ID`),
    CONSTRAINT `fk_renta_cliente`
        FOREIGN KEY (`Cliente_ID`) REFERENCES `cliente` (`Cliente_ID`)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    -- La fecha de devolución nunca puede ser anterior a la de inicio.
    CONSTRAINT `chk_renta_fechas` CHECK (`Termina` IS NULL OR `Termina` >= `Inicia`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci
  COMMENT = 'Encabezado de cada alquiler realizado por un cliente.';

-- =====================================================================================
-- TABLA: ejemplar_renta
-- Resuelve la relación N-M "una renta puede llevar varios ejemplares / un ejemplar
-- puede aparecer en varias rentas (en momentos distintos)". Llave primaria subrogada
-- por requisito del ejercicio; se conserva la combinación de llaves de los padres
-- como restricción UNIQUE.
-- =====================================================================================
CREATE TABLE IF NOT EXISTS `ejemplar_renta` (
    `Ejemplar_Renta_ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `Renta_ID` INT UNSIGNED NOT NULL,
    `Ejemplar_ID` INT UNSIGNED NOT NULL,
    -- Fecha de entrega física al cliente; NULL si aún no se ha entregado.
    `Entrega` DATE NULL,
    PRIMARY KEY (`Ejemplar_Renta_ID`),
    CONSTRAINT `uq_ejemplar_renta_renta_ejemplar` UNIQUE (`Renta_ID`, `Ejemplar_ID`),
    CONSTRAINT `fk_ejemplar_renta_renta`
        FOREIGN KEY (`Renta_ID`) REFERENCES `renta` (`Renta_ID`)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT `fk_ejemplar_renta_ejemplar`
        FOREIGN KEY (`Ejemplar_ID`) REFERENCES `ejemplar` (`Ejemplar_ID`)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci
  COMMENT = 'Entidad intermedia que resuelve la relación N-M entre renta y ejemplar.';

-- =====================================================================================
-- TRIGGERS: trg_cliente_aval_diferente_insert / trg_cliente_aval_diferente_update
-- Regla de negocio: un cliente no puede ser su propio aval. No se puede expresar con
-- CHECK porque Cliente_ID es AUTO_INCREMENT (ver comentario en la tabla cliente), por
-- lo que se valida mediante triggers en INSERT y en UPDATE.
-- =====================================================================================
DELIMITER $$

CREATE TRIGGER `trg_cliente_aval_diferente_insert`
BEFORE INSERT ON `cliente`
FOR EACH ROW
BEGIN
    IF NEW.`Aval_Cliente_ID` IS NOT NULL AND NEW.`Aval_Cliente_ID` = NEW.`Cliente_ID` THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Un cliente no puede ser su propio aval.';
    END IF;
END$$

CREATE TRIGGER `trg_cliente_aval_diferente_update`
BEFORE UPDATE ON `cliente`
FOR EACH ROW
BEGIN
    IF NEW.`Aval_Cliente_ID` IS NOT NULL AND NEW.`Aval_Cliente_ID` = NEW.`Cliente_ID` THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Un cliente no puede ser su propio aval.';
    END IF;
END$$

DELIMITER ;

-- =====================================================================================
-- TRIGGER: trg_ejemplar_renta_max_4
-- Regla de negocio del enunciado: "Cada socio puede tener alquilados, en un momento
-- dado, 4 ejemplares como máximo". Se valida antes de insertar un nuevo renglón de
-- ejemplar_renta cuyo ejemplar todavía no ha sido devuelto (Entrega IS NULL).
-- =====================================================================================
DELIMITER $$

CREATE TRIGGER `trg_ejemplar_renta_max_4`
BEFORE INSERT ON `ejemplar_renta`
FOR EACH ROW
BEGIN
    -- Cuenta cuántos ejemplares tiene actualmente pendientes de devolución el cliente
    -- dueño de la renta a la que se está agregando este nuevo ejemplar.
    DECLARE ejemplares_activos INT UNSIGNED;

    SELECT COUNT(*)
    INTO ejemplares_activos
    FROM `ejemplar_renta` er
    INNER JOIN `renta` r ON r.`Renta_ID` = er.`Renta_ID`
    WHERE r.`Cliente_ID` = (SELECT `Cliente_ID` FROM `renta` WHERE `Renta_ID` = NEW.`Renta_ID`)
      AND er.`Entrega` IS NULL;

    -- Si el cliente ya tiene 4 ejemplares sin devolver, se rechaza la nueva inserción.
    IF ejemplares_activos >= 4 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El cliente ya tiene 4 ejemplares alquilados sin devolver.';
    END IF;
END$$

DELIMITER ;
