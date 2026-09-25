-- =====================================================================================
-- Datos de prueba (DML) para Glob-Gusters Video-Club
-- Autor: Andrés Felipe Gutiérrez Rivera
-- Fecha: 2024-06-10
--
-- Este script inserta datos ficticios en todas las tablas del modelo creado en
-- glob_gusters.sql. El orden de inserción respeta las dependencias de llave foránea:
-- primero los catálogos (nacionalidad, productora, estado), luego director/actor/
-- pelicula, después reparto, cliente, ejemplar, renta y finalmente ejemplar_renta.
-- =====================================================================================

-- Selecciona el esquema donde se insertarán los datos.
USE `glob_gusters`;

-- -------------------------------------------------------------------------------------
-- Catálogo: nacionalidad
-- -------------------------------------------------------------------------------------
-- Inserta los países de origen usados por actores, directores y películas.
INSERT INTO `nacionalidad` (`Nombre`) VALUES
    ('Estados Unidos'),  -- Nacionalidad_ID = 1
    ('España'),          -- Nacionalidad_ID = 2
    ('Reino Unido'),     -- Nacionalidad_ID = 3
    ('Francia'),         -- Nacionalidad_ID = 4
    ('México');          -- Nacionalidad_ID = 5

-- -------------------------------------------------------------------------------------
-- Catálogo: productora
-- -------------------------------------------------------------------------------------
-- Inserta las casas productoras que aparecen en el catálogo de películas.
INSERT INTO `productora` (`Nombre`) VALUES
    ('M.G.M.'),            -- Productora_ID = 1
    ('Warner Bros.'),      -- Productora_ID = 2
    ('Universal Pictures'),-- Productora_ID = 3
    ('El Deseo');          -- Productora_ID = 4

-- -------------------------------------------------------------------------------------
-- Catálogo: estado
-- -------------------------------------------------------------------------------------
-- Inserta los posibles estados de conservación de un ejemplar físico.
INSERT INTO `estado` (`Nombre`) VALUES
    ('Nuevo'),    -- Estado_ID = 1
    ('Bueno'),    -- Estado_ID = 2
    ('Regular'),  -- Estado_ID = 3
    ('Dañado');   -- Estado_ID = 4

-- -------------------------------------------------------------------------------------
-- Tabla: director
-- -------------------------------------------------------------------------------------
-- Inserta directores, referenciando la nacionalidad ya cargada.
INSERT INTO `director` (`Nombre`, `Nacionalidad_ID`) VALUES
    ('Mervyn LeRoy', 1),        -- Director_ID = 1, Estados Unidos
    ('Pedro Almodóvar', 2),     -- Director_ID = 2, España
    ('Christopher Nolan', 3),   -- Director_ID = 3, Reino Unido
    ('Luc Besson', 4);          -- Director_ID = 4, Francia

-- -------------------------------------------------------------------------------------
-- Tabla: pelicula
-- -------------------------------------------------------------------------------------
-- Inserta películas referenciando nacionalidad, productora y director.
INSERT INTO `pelicula` (`Titulo`, `Anio`, `Nacionalidad_ID`, `Productora_ID`, `Director_ID`) VALUES
    ('Quo Vadis', 1951, 1, 1, 1),                 -- Pelicula_ID = 1
    ('Todo sobre mi madre', 1999, 2, 4, 2),       -- Pelicula_ID = 2
    ('Interstellar', 2014, 3, 3, 3),              -- Pelicula_ID = 3
    ('El quinto elemento', 1997, 4, 2, 4);        -- Pelicula_ID = 4

-- -------------------------------------------------------------------------------------
-- Tabla: actor
-- -------------------------------------------------------------------------------------
-- Inserta actores referenciando su nacionalidad.
INSERT INTO `actor` (`Nombre`, `Nacionalidad_ID`, `Sexo`) VALUES
    ('Robert Taylor', 1, 'M'),      -- Actor_ID = 1
    ('Deborah Kerr', 3, 'F'),       -- Actor_ID = 2
    ('Cecilia Roth', 5, 'F'),       -- Actor_ID = 3
    ('Matthew McConaughey', 1, 'M'),-- Actor_ID = 4
    ('Anne Hathaway', 1, 'F'),      -- Actor_ID = 5
    ('Milla Jovovich', 1, 'F');     -- Actor_ID = 6

-- -------------------------------------------------------------------------------------
-- Tabla: reparto
-- -------------------------------------------------------------------------------------
-- Asocia actores a películas indicando el rol desempeñado (Principal/Secundario).
INSERT INTO `reparto` (`Pelicula_ID`, `Actor_ID`, `Rol`) VALUES
    (1, 1, 'Principal'),   -- Quo Vadis - Robert Taylor
    (1, 2, 'Principal'),   -- Quo Vadis - Deborah Kerr
    (2, 3, 'Principal'),   -- Todo sobre mi madre - Cecilia Roth
    (3, 4, 'Principal'),   -- Interstellar - Matthew McConaughey
    (3, 5, 'Secundario'),  -- Interstellar - Anne Hathaway
    (4, 6, 'Principal');   -- El quinto elemento - Milla Jovovich

-- -------------------------------------------------------------------------------------
-- Tabla: cliente
-- -------------------------------------------------------------------------------------
-- El primer socio no tiene aval (es el socio fundador); los siguientes son avalados
-- por un socio previamente registrado, cumpliendo la regla de negocio del enunciado.
INSERT INTO `cliente` (`Dni`, `Nombre`, `Direccion`, `Telefono`, `Aval_Cliente_ID`) VALUES
    ('1000000001', 'Laura Gómez', 'Calle 10 # 5-20', '3001234567', NULL);        -- Cliente_ID = 1

INSERT INTO `cliente` (`Dni`, `Nombre`, `Direccion`, `Telefono`, `Aval_Cliente_ID`) VALUES
    ('1000000002', 'Carlos Pérez', 'Carrera 8 # 12-45', '3007654321', 1),        -- Cliente_ID = 2, avalado por Laura
    ('1000000003', 'María Rodríguez', 'Av. Siempre Viva 742', '3009876543', 1), -- Cliente_ID = 3, avalado por Laura
    ('1000000004', 'Andrés Torres', 'Diagonal 45 # 9-10', '3004561234', 2);     -- Cliente_ID = 4, avalado por Carlos

-- -------------------------------------------------------------------------------------
-- Tabla: ejemplar
-- -------------------------------------------------------------------------------------
-- Cada película puede tener uno o varios ejemplares físicos con su propio estado.
INSERT INTO `ejemplar` (`Numero`, `Pelicula_ID`, `Estado_ID`) VALUES
    (1, 1, 2),  -- Ejemplar_ID = 1, Quo Vadis, Bueno
    (2, 1, 3),  -- Ejemplar_ID = 2, Quo Vadis, Regular
    (1, 2, 1),  -- Ejemplar_ID = 3, Todo sobre mi madre, Nuevo
    (1, 3, 1),  -- Ejemplar_ID = 4, Interstellar, Nuevo
    (2, 3, 2),  -- Ejemplar_ID = 5, Interstellar, Bueno
    (1, 4, 2);  -- Ejemplar_ID = 6, El quinto elemento, Bueno

-- -------------------------------------------------------------------------------------
-- Tabla: renta
-- -------------------------------------------------------------------------------------
-- Encabezados de alquiler: la primera renta sigue activa (Termina = NULL).
INSERT INTO `renta` (`Cliente_ID`, `Inicia`, `Termina`) VALUES
    (1, '2024-05-01', NULL),          -- Renta_ID = 1, Laura, activa
    (2, '2024-05-02', '2024-05-05'),  -- Renta_ID = 2, Carlos, devuelta
    (3, '2024-05-03', NULL);          -- Renta_ID = 3, María, activa

-- -------------------------------------------------------------------------------------
-- Tabla: ejemplar_renta
-- -------------------------------------------------------------------------------------
-- Detalle de qué ejemplares se llevó cada renta; Entrega NULL indica que el ejemplar
-- aún no ha sido devuelto físicamente.
INSERT INTO `ejemplar_renta` (`Renta_ID`, `Ejemplar_ID`, `Entrega`) VALUES
    (1, 1, NULL),           -- Laura se llevó el ejemplar 1 de Quo Vadis (pendiente)
    (1, 4, NULL),           -- Laura también se llevó Interstellar ejemplar 1 (pendiente)
    (2, 3, '2024-05-05'),   -- Carlos devolvió Todo sobre mi madre
    (3, 6, NULL);           -- María se llevó El quinto elemento (pendiente)
