-- =====================================================================================
-- Datos de prueba (DML) para Glob-Gusters Video-Club
-- Autor: Andrés Felipe Gutiérrez Rivera
-- Fecha: 2024-06-10
--
-- Este script inserta datos ficticios en todas las tablas del modelo creado en
-- glob_gusters.sql. El orden de inserción respeta las dependencias de llave foránea:
-- primero los catálogos (nacionalidad, productora, estado), luego director/actor/
-- pelicula, después reparto, cliente, ejemplar, renta y finalmente ejemplar_renta.
--
-- EJECUCIÓN SEGURA / IDEMPOTENCIA:
--   Este script puede ejecutarse varias veces sobre la misma base de datos sin crear
--   filas duplicadas ni lanzar errores. Para lograrlo:
--   - No se usan IDs numéricos fijos como llave foránea (los valores AUTO_INCREMENT
--     pueden variar entre corridas); en su lugar cada FK se resuelve con una
--     subconsulta por su llave natural (nombre, título+año, DNI, etc.).
--   - Las tablas con restricción UNIQUE (nacionalidad, productora, estado, pelicula,
--     cliente, ejemplar, reparto, ejemplar_renta) usan INSERT IGNORE: si la fila ya
--     existe, la inserción se descarta en silencio.
--   - director y actor no tienen una restricción UNIQUE natural, así que se protegen
--     con "INSERT ... SELECT ... WHERE NOT EXISTS" para no duplicarlos.
--   - renta no tiene una restricción UNIQUE (un cliente sí puede alquilar más de una
--     vez el mismo día en la vida real), así que cada fila de este script se protege
--     también con WHERE NOT EXISTS sobre la combinación cliente + fecha de inicio,
--     que identifica de forma única a cada renta de este conjunto de datos de
--     ejemplo. NO se usa INSERT IGNORE aquí ni en ejemplar_renta, porque cliente y
--     ejemplar_renta tienen triggers BEFORE INSERT con SIGNAL (reglas de negocio) que
--     IGNORE no suprime: un intento de inserción duplicada igual dispararía la
--     validación del trigger. Al filtrar con WHERE NOT EXISTS antes, esas filas ya
--     existentes ni siquiera intentan insertarse, y el trigger nunca se evalúa dos
--     veces para el mismo dato.
-- =====================================================================================

-- Selecciona el esquema donde se insertarán los datos.
USE `glob_gusters`;

-- -------------------------------------------------------------------------------------
-- Catálogo: nacionalidad (UNIQUE en Nombre -> INSERT IGNORE es suficiente)
-- -------------------------------------------------------------------------------------
INSERT IGNORE INTO `nacionalidad` (`Nombre`) VALUES
    ('Estados Unidos'),
    ('España'),
    ('Reino Unido'),
    ('Francia'),
    ('México');

-- -------------------------------------------------------------------------------------
-- Catálogo: productora (UNIQUE en Nombre -> INSERT IGNORE es suficiente)
-- -------------------------------------------------------------------------------------
INSERT IGNORE INTO `productora` (`Nombre`) VALUES
    ('M.G.M.'),
    ('Warner Bros.'),
    ('Universal Pictures'),
    ('El Deseo');

-- -------------------------------------------------------------------------------------
-- Catálogo: estado (UNIQUE en Nombre -> INSERT IGNORE es suficiente)
-- -------------------------------------------------------------------------------------
INSERT IGNORE INTO `estado` (`Nombre`) VALUES
    ('Nuevo'),
    ('Bueno'),
    ('Regular'),
    ('Dañado');

-- -------------------------------------------------------------------------------------
-- Tabla: director (sin UNIQUE natural -> se protege con WHERE NOT EXISTS por Nombre)
-- -------------------------------------------------------------------------------------
INSERT INTO `director` (`Nombre`, `Nacionalidad_ID`)
SELECT 'Mervyn LeRoy', (SELECT `Nacionalidad_ID` FROM `nacionalidad` WHERE `Nombre` = 'Estados Unidos')
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `director` WHERE `Nombre` = 'Mervyn LeRoy');

INSERT INTO `director` (`Nombre`, `Nacionalidad_ID`)
SELECT 'Pedro Almodóvar', (SELECT `Nacionalidad_ID` FROM `nacionalidad` WHERE `Nombre` = 'España')
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `director` WHERE `Nombre` = 'Pedro Almodóvar');

INSERT INTO `director` (`Nombre`, `Nacionalidad_ID`)
SELECT 'Christopher Nolan', (SELECT `Nacionalidad_ID` FROM `nacionalidad` WHERE `Nombre` = 'Reino Unido')
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `director` WHERE `Nombre` = 'Christopher Nolan');

INSERT INTO `director` (`Nombre`, `Nacionalidad_ID`)
SELECT 'Luc Besson', (SELECT `Nacionalidad_ID` FROM `nacionalidad` WHERE `Nombre` = 'Francia')
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `director` WHERE `Nombre` = 'Luc Besson');

-- -------------------------------------------------------------------------------------
-- Tabla: pelicula (UNIQUE en Titulo+Anio -> INSERT IGNORE es suficiente)
-- -------------------------------------------------------------------------------------
INSERT IGNORE INTO `pelicula` (`Titulo`, `Anio`, `Nacionalidad_ID`, `Productora_ID`, `Director_ID`)
VALUES (
    'Quo Vadis', 1951,
    (SELECT `Nacionalidad_ID` FROM `nacionalidad` WHERE `Nombre` = 'Estados Unidos'),
    (SELECT `Productora_ID` FROM `productora` WHERE `Nombre` = 'M.G.M.'),
    (SELECT `Director_ID` FROM `director` WHERE `Nombre` = 'Mervyn LeRoy')
);

INSERT IGNORE INTO `pelicula` (`Titulo`, `Anio`, `Nacionalidad_ID`, `Productora_ID`, `Director_ID`)
VALUES (
    'Todo sobre mi madre', 1999,
    (SELECT `Nacionalidad_ID` FROM `nacionalidad` WHERE `Nombre` = 'España'),
    (SELECT `Productora_ID` FROM `productora` WHERE `Nombre` = 'El Deseo'),
    (SELECT `Director_ID` FROM `director` WHERE `Nombre` = 'Pedro Almodóvar')
);

INSERT IGNORE INTO `pelicula` (`Titulo`, `Anio`, `Nacionalidad_ID`, `Productora_ID`, `Director_ID`)
VALUES (
    'Interstellar', 2014,
    (SELECT `Nacionalidad_ID` FROM `nacionalidad` WHERE `Nombre` = 'Reino Unido'),
    (SELECT `Productora_ID` FROM `productora` WHERE `Nombre` = 'Universal Pictures'),
    (SELECT `Director_ID` FROM `director` WHERE `Nombre` = 'Christopher Nolan')
);

INSERT IGNORE INTO `pelicula` (`Titulo`, `Anio`, `Nacionalidad_ID`, `Productora_ID`, `Director_ID`)
VALUES (
    'El quinto elemento', 1997,
    (SELECT `Nacionalidad_ID` FROM `nacionalidad` WHERE `Nombre` = 'Francia'),
    (SELECT `Productora_ID` FROM `productora` WHERE `Nombre` = 'Warner Bros.'),
    (SELECT `Director_ID` FROM `director` WHERE `Nombre` = 'Luc Besson')
);

-- -------------------------------------------------------------------------------------
-- Tabla: actor (sin UNIQUE natural -> se protege con WHERE NOT EXISTS por Nombre)
-- -------------------------------------------------------------------------------------
INSERT INTO `actor` (`Nombre`, `Nacionalidad_ID`, `Sexo`)
SELECT 'Robert Taylor', (SELECT `Nacionalidad_ID` FROM `nacionalidad` WHERE `Nombre` = 'Estados Unidos'), 'M'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `actor` WHERE `Nombre` = 'Robert Taylor');

INSERT INTO `actor` (`Nombre`, `Nacionalidad_ID`, `Sexo`)
SELECT 'Deborah Kerr', (SELECT `Nacionalidad_ID` FROM `nacionalidad` WHERE `Nombre` = 'Reino Unido'), 'F'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `actor` WHERE `Nombre` = 'Deborah Kerr');

INSERT INTO `actor` (`Nombre`, `Nacionalidad_ID`, `Sexo`)
SELECT 'Cecilia Roth', (SELECT `Nacionalidad_ID` FROM `nacionalidad` WHERE `Nombre` = 'México'), 'F'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `actor` WHERE `Nombre` = 'Cecilia Roth');

INSERT INTO `actor` (`Nombre`, `Nacionalidad_ID`, `Sexo`)
SELECT 'Matthew McConaughey', (SELECT `Nacionalidad_ID` FROM `nacionalidad` WHERE `Nombre` = 'Estados Unidos'), 'M'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `actor` WHERE `Nombre` = 'Matthew McConaughey');

INSERT INTO `actor` (`Nombre`, `Nacionalidad_ID`, `Sexo`)
SELECT 'Anne Hathaway', (SELECT `Nacionalidad_ID` FROM `nacionalidad` WHERE `Nombre` = 'Estados Unidos'), 'F'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `actor` WHERE `Nombre` = 'Anne Hathaway');

INSERT INTO `actor` (`Nombre`, `Nacionalidad_ID`, `Sexo`)
SELECT 'Milla Jovovich', (SELECT `Nacionalidad_ID` FROM `nacionalidad` WHERE `Nombre` = 'Estados Unidos'), 'F'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `actor` WHERE `Nombre` = 'Milla Jovovich');

-- -------------------------------------------------------------------------------------
-- Tabla: reparto (UNIQUE en Pelicula_ID+Actor_ID -> INSERT IGNORE es suficiente)
-- -------------------------------------------------------------------------------------
INSERT IGNORE INTO `reparto` (`Pelicula_ID`, `Actor_ID`, `Rol`) VALUES
    ((SELECT `Pelicula_ID` FROM `pelicula` WHERE `Titulo` = 'Quo Vadis' AND `Anio` = 1951),
     (SELECT `Actor_ID` FROM `actor` WHERE `Nombre` = 'Robert Taylor'), 'Principal'),
    ((SELECT `Pelicula_ID` FROM `pelicula` WHERE `Titulo` = 'Quo Vadis' AND `Anio` = 1951),
     (SELECT `Actor_ID` FROM `actor` WHERE `Nombre` = 'Deborah Kerr'), 'Principal'),
    ((SELECT `Pelicula_ID` FROM `pelicula` WHERE `Titulo` = 'Todo sobre mi madre' AND `Anio` = 1999),
     (SELECT `Actor_ID` FROM `actor` WHERE `Nombre` = 'Cecilia Roth'), 'Principal'),
    ((SELECT `Pelicula_ID` FROM `pelicula` WHERE `Titulo` = 'Interstellar' AND `Anio` = 2014),
     (SELECT `Actor_ID` FROM `actor` WHERE `Nombre` = 'Matthew McConaughey'), 'Principal'),
    ((SELECT `Pelicula_ID` FROM `pelicula` WHERE `Titulo` = 'Interstellar' AND `Anio` = 2014),
     (SELECT `Actor_ID` FROM `actor` WHERE `Nombre` = 'Anne Hathaway'), 'Secundario'),
    ((SELECT `Pelicula_ID` FROM `pelicula` WHERE `Titulo` = 'El quinto elemento' AND `Anio` = 1997),
     (SELECT `Actor_ID` FROM `actor` WHERE `Nombre` = 'Milla Jovovich'), 'Principal');

-- -------------------------------------------------------------------------------------
-- Tabla: cliente (UNIQUE en Dni -> INSERT IGNORE es suficiente; el aval se resuelve
-- por DNI del socio avalista, nunca por Cliente_ID numérico).
-- El primer socio no tiene aval (es el socio fundador); los siguientes son avalados
-- por un socio previamente registrado, cumpliendo la regla de negocio del enunciado.
-- -------------------------------------------------------------------------------------
INSERT IGNORE INTO `cliente` (`Dni`, `Nombre`, `Direccion`, `Telefono`, `Aval_Cliente_ID`)
VALUES ('1000000001', 'Laura Gómez', 'Calle 10 # 5-20', '3001234567', NULL);

-- Nota: la subconsulta que resuelve el aval se envuelve en una tabla derivada
-- (SELECT ... FROM (SELECT ...) AS tmp) porque MariaDB no permite que un INSERT
-- referencie directamente en VALUES() la misma tabla en la que se está insertando
-- (ERROR 1093: "Table 'cliente' is specified twice"); envolver la subconsulta la
-- materializa primero y evita la restricción.
INSERT IGNORE INTO `cliente` (`Dni`, `Nombre`, `Direccion`, `Telefono`, `Aval_Cliente_ID`)
VALUES ('1000000002', 'Carlos Pérez', 'Carrera 8 # 12-45', '3007654321',
        (SELECT `Cliente_ID` FROM (SELECT `Cliente_ID` FROM `cliente` WHERE `Dni` = '1000000001') AS `aval`));

INSERT IGNORE INTO `cliente` (`Dni`, `Nombre`, `Direccion`, `Telefono`, `Aval_Cliente_ID`)
VALUES ('1000000003', 'María Rodríguez', 'Av. Siempre Viva 742', '3009876543',
        (SELECT `Cliente_ID` FROM (SELECT `Cliente_ID` FROM `cliente` WHERE `Dni` = '1000000001') AS `aval`));

INSERT IGNORE INTO `cliente` (`Dni`, `Nombre`, `Direccion`, `Telefono`, `Aval_Cliente_ID`)
VALUES ('1000000004', 'Andrés Torres', 'Diagonal 45 # 9-10', '3004561234',
        (SELECT `Cliente_ID` FROM (SELECT `Cliente_ID` FROM `cliente` WHERE `Dni` = '1000000002') AS `aval`));

-- -------------------------------------------------------------------------------------
-- Tabla: ejemplar (UNIQUE en Pelicula_ID+Numero -> INSERT IGNORE es suficiente)
-- -------------------------------------------------------------------------------------
INSERT IGNORE INTO `ejemplar` (`Numero`, `Pelicula_ID`, `Estado_ID`) VALUES
    (1, (SELECT `Pelicula_ID` FROM `pelicula` WHERE `Titulo` = 'Quo Vadis' AND `Anio` = 1951),
        (SELECT `Estado_ID` FROM `estado` WHERE `Nombre` = 'Bueno')),
    (2, (SELECT `Pelicula_ID` FROM `pelicula` WHERE `Titulo` = 'Quo Vadis' AND `Anio` = 1951),
        (SELECT `Estado_ID` FROM `estado` WHERE `Nombre` = 'Regular')),
    (1, (SELECT `Pelicula_ID` FROM `pelicula` WHERE `Titulo` = 'Todo sobre mi madre' AND `Anio` = 1999),
        (SELECT `Estado_ID` FROM `estado` WHERE `Nombre` = 'Nuevo')),
    (1, (SELECT `Pelicula_ID` FROM `pelicula` WHERE `Titulo` = 'Interstellar' AND `Anio` = 2014),
        (SELECT `Estado_ID` FROM `estado` WHERE `Nombre` = 'Nuevo')),
    (2, (SELECT `Pelicula_ID` FROM `pelicula` WHERE `Titulo` = 'Interstellar' AND `Anio` = 2014),
        (SELECT `Estado_ID` FROM `estado` WHERE `Nombre` = 'Bueno')),
    (1, (SELECT `Pelicula_ID` FROM `pelicula` WHERE `Titulo` = 'El quinto elemento' AND `Anio` = 1997),
        (SELECT `Estado_ID` FROM `estado` WHERE `Nombre` = 'Bueno'));

-- -------------------------------------------------------------------------------------
-- Tabla: renta (sin UNIQUE natural -> se protege con WHERE NOT EXISTS sobre
-- Cliente_ID + Inicia, que identifica de forma única cada renta de este conjunto de
-- datos de ejemplo).
-- -------------------------------------------------------------------------------------
INSERT INTO `renta` (`Cliente_ID`, `Inicia`, `Termina`)
SELECT (SELECT `Cliente_ID` FROM `cliente` WHERE `Dni` = '1000000001'), '2024-05-01', NULL
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM `renta`
    WHERE `Cliente_ID` = (SELECT `Cliente_ID` FROM `cliente` WHERE `Dni` = '1000000001')
      AND `Inicia` = '2024-05-01'
);

INSERT INTO `renta` (`Cliente_ID`, `Inicia`, `Termina`)
SELECT (SELECT `Cliente_ID` FROM `cliente` WHERE `Dni` = '1000000002'), '2024-05-02', '2024-05-05'
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM `renta`
    WHERE `Cliente_ID` = (SELECT `Cliente_ID` FROM `cliente` WHERE `Dni` = '1000000002')
      AND `Inicia` = '2024-05-02'
);

INSERT INTO `renta` (`Cliente_ID`, `Inicia`, `Termina`)
SELECT (SELECT `Cliente_ID` FROM `cliente` WHERE `Dni` = '1000000003'), '2024-05-03', NULL
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM `renta`
    WHERE `Cliente_ID` = (SELECT `Cliente_ID` FROM `cliente` WHERE `Dni` = '1000000003')
      AND `Inicia` = '2024-05-03'
);

-- -------------------------------------------------------------------------------------
-- Tabla: ejemplar_renta (UNIQUE en Renta_ID+Ejemplar_ID, pero con trigger de negocio
-- -> se protege con WHERE NOT EXISTS en vez de INSERT IGNORE, para que un intento de
-- inserción duplicada ni siquiera llegue a evaluar el trigger trg_ejemplar_renta_max_4).
-- Entrega NULL indica que el ejemplar aún no ha sido devuelto físicamente.
-- -------------------------------------------------------------------------------------
INSERT INTO `ejemplar_renta` (`Renta_ID`, `Ejemplar_ID`, `Entrega`)
SELECT
    (SELECT `Renta_ID` FROM `renta`
      WHERE `Cliente_ID` = (SELECT `Cliente_ID` FROM `cliente` WHERE `Dni` = '1000000001') AND `Inicia` = '2024-05-01'),
    (SELECT `Ejemplar_ID` FROM `ejemplar` e INNER JOIN `pelicula` p ON p.`Pelicula_ID` = e.`Pelicula_ID`
      WHERE p.`Titulo` = 'Quo Vadis' AND p.`Anio` = 1951 AND e.`Numero` = 1),
    NULL
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM `ejemplar_renta`
    WHERE `Renta_ID` = (SELECT `Renta_ID` FROM `renta`
                          WHERE `Cliente_ID` = (SELECT `Cliente_ID` FROM `cliente` WHERE `Dni` = '1000000001') AND `Inicia` = '2024-05-01')
      AND `Ejemplar_ID` = (SELECT `Ejemplar_ID` FROM `ejemplar` e INNER JOIN `pelicula` p ON p.`Pelicula_ID` = e.`Pelicula_ID`
                             WHERE p.`Titulo` = 'Quo Vadis' AND p.`Anio` = 1951 AND e.`Numero` = 1)
);

INSERT INTO `ejemplar_renta` (`Renta_ID`, `Ejemplar_ID`, `Entrega`)
SELECT
    (SELECT `Renta_ID` FROM `renta`
      WHERE `Cliente_ID` = (SELECT `Cliente_ID` FROM `cliente` WHERE `Dni` = '1000000001') AND `Inicia` = '2024-05-01'),
    (SELECT `Ejemplar_ID` FROM `ejemplar` e INNER JOIN `pelicula` p ON p.`Pelicula_ID` = e.`Pelicula_ID`
      WHERE p.`Titulo` = 'Interstellar' AND p.`Anio` = 2014 AND e.`Numero` = 1),
    NULL
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM `ejemplar_renta`
    WHERE `Renta_ID` = (SELECT `Renta_ID` FROM `renta`
                          WHERE `Cliente_ID` = (SELECT `Cliente_ID` FROM `cliente` WHERE `Dni` = '1000000001') AND `Inicia` = '2024-05-01')
      AND `Ejemplar_ID` = (SELECT `Ejemplar_ID` FROM `ejemplar` e INNER JOIN `pelicula` p ON p.`Pelicula_ID` = e.`Pelicula_ID`
                             WHERE p.`Titulo` = 'Interstellar' AND p.`Anio` = 2014 AND e.`Numero` = 1)
);

INSERT INTO `ejemplar_renta` (`Renta_ID`, `Ejemplar_ID`, `Entrega`)
SELECT
    (SELECT `Renta_ID` FROM `renta`
      WHERE `Cliente_ID` = (SELECT `Cliente_ID` FROM `cliente` WHERE `Dni` = '1000000002') AND `Inicia` = '2024-05-02'),
    (SELECT `Ejemplar_ID` FROM `ejemplar` e INNER JOIN `pelicula` p ON p.`Pelicula_ID` = e.`Pelicula_ID`
      WHERE p.`Titulo` = 'Todo sobre mi madre' AND p.`Anio` = 1999 AND e.`Numero` = 1),
    '2024-05-05'
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM `ejemplar_renta`
    WHERE `Renta_ID` = (SELECT `Renta_ID` FROM `renta`
                          WHERE `Cliente_ID` = (SELECT `Cliente_ID` FROM `cliente` WHERE `Dni` = '1000000002') AND `Inicia` = '2024-05-02')
      AND `Ejemplar_ID` = (SELECT `Ejemplar_ID` FROM `ejemplar` e INNER JOIN `pelicula` p ON p.`Pelicula_ID` = e.`Pelicula_ID`
                             WHERE p.`Titulo` = 'Todo sobre mi madre' AND p.`Anio` = 1999 AND e.`Numero` = 1)
);

INSERT INTO `ejemplar_renta` (`Renta_ID`, `Ejemplar_ID`, `Entrega`)
SELECT
    (SELECT `Renta_ID` FROM `renta`
      WHERE `Cliente_ID` = (SELECT `Cliente_ID` FROM `cliente` WHERE `Dni` = '1000000003') AND `Inicia` = '2024-05-03'),
    (SELECT `Ejemplar_ID` FROM `ejemplar` e INNER JOIN `pelicula` p ON p.`Pelicula_ID` = e.`Pelicula_ID`
      WHERE p.`Titulo` = 'El quinto elemento' AND p.`Anio` = 1997 AND e.`Numero` = 1),
    NULL
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM `ejemplar_renta`
    WHERE `Renta_ID` = (SELECT `Renta_ID` FROM `renta`
                          WHERE `Cliente_ID` = (SELECT `Cliente_ID` FROM `cliente` WHERE `Dni` = '1000000003') AND `Inicia` = '2024-05-03')
      AND `Ejemplar_ID` = (SELECT `Ejemplar_ID` FROM `ejemplar` e INNER JOIN `pelicula` p ON p.`Pelicula_ID` = e.`Pelicula_ID`
                             WHERE p.`Titulo` = 'El quinto elemento' AND p.`Anio` = 1997 AND e.`Numero` = 1)
);
