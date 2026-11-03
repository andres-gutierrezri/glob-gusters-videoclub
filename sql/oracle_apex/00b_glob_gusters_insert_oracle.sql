-- =====================================================================================
-- Datos de prueba (DML) para Glob-Gusters Video-Club - Oracle APEX
-- Autor: Andrés Felipe Gutiérrez Rivera
--
-- Conversión de glob_gusters_insert.sql (MariaDB) a Oracle.
-- Debe ejecutarse DESPUÉS de glob_gusters_oracle_apex.sql (creación de tablas).
--
-- EJECUCIÓN SEGURA / IDEMPOTENCIA:
--   Cada INSERT se reemplazó por un MERGE ... WHEN NOT MATCHED THEN INSERT, que sólo
--   inserta las filas que aún no existen (equivale a INSERT IGNORE y a
--   INSERT ... WHERE NOT EXISTS de MariaDB). Las llaves foráneas se resuelven por su
--   llave natural (nombre, título+año, DNI), nunca por IDs fijos, y el script puede
--   ejecutarse varias veces sin duplicar filas ni lanzar errores.
-- =====================================================================================

-- -------------------------------------------------------------------------------------
-- Catálogo: nacionalidad
-- -------------------------------------------------------------------------------------
MERGE INTO nacionalidad t
USING (
    SELECT 'Estados Unidos' AS nombre FROM dual UNION ALL
    SELECT 'España'         FROM dual UNION ALL
    SELECT 'Reino Unido'    FROM dual UNION ALL
    SELECT 'Francia'        FROM dual UNION ALL
    SELECT 'México'         FROM dual
) s
ON (t.nombre = s.nombre)
WHEN NOT MATCHED THEN
    INSERT (nombre) VALUES (s.nombre);

-- -------------------------------------------------------------------------------------
-- Catálogo: productora
-- -------------------------------------------------------------------------------------
MERGE INTO productora t
USING (
    SELECT 'M.G.M.' AS nombre         FROM dual UNION ALL
    SELECT 'Warner Bros.'             FROM dual UNION ALL
    SELECT 'Universal Pictures'       FROM dual UNION ALL
    SELECT 'El Deseo'                 FROM dual
) s
ON (t.nombre = s.nombre)
WHEN NOT MATCHED THEN
    INSERT (nombre) VALUES (s.nombre);

-- -------------------------------------------------------------------------------------
-- Catálogo: estado
-- -------------------------------------------------------------------------------------
MERGE INTO estado t
USING (
    SELECT 'Nuevo' AS nombre FROM dual UNION ALL
    SELECT 'Bueno'           FROM dual UNION ALL
    SELECT 'Regular'         FROM dual UNION ALL
    SELECT 'Dañado'          FROM dual
) s
ON (t.nombre = s.nombre)
WHEN NOT MATCHED THEN
    INSERT (nombre) VALUES (s.nombre);

-- -------------------------------------------------------------------------------------
-- Tabla: director (llave natural: nombre)
-- -------------------------------------------------------------------------------------
MERGE INTO director d
USING (
    SELECT x.nombre, n.nacionalidad_id
    FROM (
        SELECT 'Mervyn LeRoy' AS nombre, 'Estados Unidos' AS nac_nombre FROM dual UNION ALL
        SELECT 'Pedro Almodóvar',         'España'                      FROM dual UNION ALL
        SELECT 'Christopher Nolan',       'Reino Unido'                 FROM dual UNION ALL
        SELECT 'Luc Besson',              'Francia'                     FROM dual
    ) x
    JOIN nacionalidad n ON n.nombre = x.nac_nombre
) s
ON (d.nombre = s.nombre)
WHEN NOT MATCHED THEN
    INSERT (nombre, nacionalidad_id) VALUES (s.nombre, s.nacionalidad_id);

-- -------------------------------------------------------------------------------------
-- Tabla: pelicula (llave natural: titulo + anio)
-- -------------------------------------------------------------------------------------
MERGE INTO pelicula p
USING (
    SELECT x.titulo, x.anio, n.nacionalidad_id, pr.productora_id, d.director_id
    FROM (
        SELECT 'Quo Vadis' AS titulo, 1951 AS anio, 'Estados Unidos' AS nac_nombre,
               'M.G.M.' AS prod_nombre, 'Mervyn LeRoy' AS dir_nombre FROM dual UNION ALL
        SELECT 'Todo sobre mi madre', 1999, 'España',
               'El Deseo', 'Pedro Almodóvar' FROM dual UNION ALL
        SELECT 'Interstellar', 2014, 'Reino Unido',
               'Universal Pictures', 'Christopher Nolan' FROM dual UNION ALL
        SELECT 'El quinto elemento', 1997, 'Francia',
               'Warner Bros.', 'Luc Besson' FROM dual
    ) x
    JOIN nacionalidad n ON n.nombre = x.nac_nombre
    JOIN productora pr  ON pr.nombre = x.prod_nombre
    JOIN director d     ON d.nombre = x.dir_nombre
) s
ON (p.titulo = s.titulo AND p.anio = s.anio)
WHEN NOT MATCHED THEN
    INSERT (titulo, anio, nacionalidad_id, productora_id, director_id)
    VALUES (s.titulo, s.anio, s.nacionalidad_id, s.productora_id, s.director_id);

-- -------------------------------------------------------------------------------------
-- Tabla: actor (llave natural: nombre)
-- -------------------------------------------------------------------------------------
MERGE INTO actor a
USING (
    SELECT x.nombre, n.nacionalidad_id, x.sexo
    FROM (
        SELECT 'Robert Taylor' AS nombre, 'Estados Unidos' AS nac_nombre, 'M' AS sexo FROM dual UNION ALL
        SELECT 'Deborah Kerr',            'Reino Unido',   'F' FROM dual UNION ALL
        SELECT 'Cecilia Roth',            'México',        'F' FROM dual UNION ALL
        SELECT 'Matthew McConaughey',     'Estados Unidos','M' FROM dual UNION ALL
        SELECT 'Anne Hathaway',           'Estados Unidos','F' FROM dual UNION ALL
        SELECT 'Milla Jovovich',          'Estados Unidos','F' FROM dual
    ) x
    JOIN nacionalidad n ON n.nombre = x.nac_nombre
) s
ON (a.nombre = s.nombre)
WHEN NOT MATCHED THEN
    INSERT (nombre, nacionalidad_id, sexo) VALUES (s.nombre, s.nacionalidad_id, s.sexo);

-- -------------------------------------------------------------------------------------
-- Tabla: reparto (llave natural: pelicula + actor)
-- -------------------------------------------------------------------------------------
MERGE INTO reparto r
USING (
    SELECT p.pelicula_id, a.actor_id, x.rol
    FROM (
        SELECT 'Quo Vadis' AS titulo, 1951 AS anio, 'Robert Taylor' AS actor_nombre, 'Principal' AS rol FROM dual UNION ALL
        SELECT 'Quo Vadis',           1951, 'Deborah Kerr',        'Principal'  FROM dual UNION ALL
        SELECT 'Todo sobre mi madre', 1999, 'Cecilia Roth',        'Principal'  FROM dual UNION ALL
        SELECT 'Interstellar',        2014, 'Matthew McConaughey', 'Principal'  FROM dual UNION ALL
        SELECT 'Interstellar',        2014, 'Anne Hathaway',       'Secundario' FROM dual UNION ALL
        SELECT 'El quinto elemento',  1997, 'Milla Jovovich',      'Principal'  FROM dual
    ) x
    JOIN pelicula p ON p.titulo = x.titulo AND p.anio = x.anio
    JOIN actor a    ON a.nombre = x.actor_nombre
) s
ON (r.pelicula_id = s.pelicula_id AND r.actor_id = s.actor_id)
WHEN NOT MATCHED THEN
    INSERT (pelicula_id, actor_id, rol) VALUES (s.pelicula_id, s.actor_id, s.rol);

-- -------------------------------------------------------------------------------------
-- Tabla: cliente (llave natural: dni)
-- El aval se resuelve por el DNI del socio avalista. Como un socio sólo puede ser
-- avalado por otro ya registrado, la carga se hace por niveles (un MERGE por nivel).
-- -------------------------------------------------------------------------------------
-- Nivel 1: socio fundador, sin aval.
MERGE INTO cliente c
USING (
    SELECT '1000000001' AS dni, 'Laura Gómez' AS nombre,
           'Calle 10 # 5-20' AS direccion, '3001234567' AS telefono
    FROM dual
) s
ON (c.dni = s.dni)
WHEN NOT MATCHED THEN
    INSERT (dni, nombre, direccion, telefono, aval_cliente_id)
    VALUES (s.dni, s.nombre, s.direccion, s.telefono, NULL);

-- Nivel 2: socios avalados por el socio fundador.
MERGE INTO cliente c
USING (
    SELECT x.dni, x.nombre, x.direccion, x.telefono, a.cliente_id AS aval_cliente_id
    FROM (
        SELECT '1000000002' AS dni, 'Carlos Pérez' AS nombre, 'Carrera 8 # 12-45' AS direccion,
               '3007654321' AS telefono, '1000000001' AS aval_dni FROM dual UNION ALL
        SELECT '1000000003', 'María Rodríguez', 'Av. Siempre Viva 742',
               '3009876543', '1000000001' FROM dual
    ) x
    JOIN cliente a ON a.dni = x.aval_dni
) s
ON (c.dni = s.dni)
WHEN NOT MATCHED THEN
    INSERT (dni, nombre, direccion, telefono, aval_cliente_id)
    VALUES (s.dni, s.nombre, s.direccion, s.telefono, s.aval_cliente_id);

-- Nivel 3: socio avalado por un socio de nivel 2.
MERGE INTO cliente c
USING (
    SELECT x.dni, x.nombre, x.direccion, x.telefono, a.cliente_id AS aval_cliente_id
    FROM (
        SELECT '1000000004' AS dni, 'Andrés Torres' AS nombre, 'Diagonal 45 # 9-10' AS direccion,
               '3004561234' AS telefono, '1000000002' AS aval_dni FROM dual
    ) x
    JOIN cliente a ON a.dni = x.aval_dni
) s
ON (c.dni = s.dni)
WHEN NOT MATCHED THEN
    INSERT (dni, nombre, direccion, telefono, aval_cliente_id)
    VALUES (s.dni, s.nombre, s.direccion, s.telefono, s.aval_cliente_id);

-- -------------------------------------------------------------------------------------
-- Tabla: ejemplar (llave natural: pelicula + numero)
-- -------------------------------------------------------------------------------------
MERGE INTO ejemplar e
USING (
    SELECT p.pelicula_id, x.numero, es.estado_id
    FROM (
        SELECT 'Quo Vadis' AS titulo, 1951 AS anio, 1 AS numero, 'Bueno' AS estado_nombre FROM dual UNION ALL
        SELECT 'Quo Vadis',           1951, 2, 'Regular' FROM dual UNION ALL
        SELECT 'Todo sobre mi madre', 1999, 1, 'Nuevo'   FROM dual UNION ALL
        SELECT 'Interstellar',        2014, 1, 'Nuevo'   FROM dual UNION ALL
        SELECT 'Interstellar',        2014, 2, 'Bueno'   FROM dual UNION ALL
        SELECT 'El quinto elemento',  1997, 1, 'Bueno'   FROM dual
    ) x
    JOIN pelicula p ON p.titulo = x.titulo AND p.anio = x.anio
    JOIN estado es  ON es.nombre = x.estado_nombre
) s
ON (e.pelicula_id = s.pelicula_id AND e.numero = s.numero)
WHEN NOT MATCHED THEN
    INSERT (numero, pelicula_id, estado_id) VALUES (s.numero, s.pelicula_id, s.estado_id);

-- -------------------------------------------------------------------------------------
-- Tabla: renta (llave natural del ejemplo: cliente + fecha de inicio)
-- TERMINA nula indica que la renta sigue activa.
-- -------------------------------------------------------------------------------------
MERGE INTO renta r
USING (
    SELECT c.cliente_id, x.inicia, x.termina
    FROM (
        SELECT '1000000001' AS dni, DATE '2024-05-01' AS inicia, CAST(NULL AS DATE) AS termina FROM dual UNION ALL
        SELECT '1000000002', DATE '2024-05-02', DATE '2024-05-05'      FROM dual UNION ALL
        SELECT '1000000003', DATE '2024-05-03', CAST(NULL AS DATE)     FROM dual
    ) x
    JOIN cliente c ON c.dni = x.dni
) s
ON (r.cliente_id = s.cliente_id AND r.inicia = s.inicia)
WHEN NOT MATCHED THEN
    INSERT (cliente_id, inicia, termina) VALUES (s.cliente_id, s.inicia, s.termina);

-- -------------------------------------------------------------------------------------
-- Tabla: ejemplar_renta (llave natural: renta + ejemplar)
-- ENTREGA nula indica que el ejemplar aún no ha sido devuelto. El trigger
-- trg_ejemplar_renta_max_4 valida la regla de máximo 4 ejemplares por socio.
-- -------------------------------------------------------------------------------------
MERGE INTO ejemplar_renta er
USING (
    SELECT r.renta_id, e.ejemplar_id, x.entrega
    FROM (
        SELECT '1000000001' AS dni, DATE '2024-05-01' AS inicia, 'Quo Vadis' AS titulo, 1951 AS anio,
               1 AS numero, CAST(NULL AS DATE) AS entrega FROM dual UNION ALL
        SELECT '1000000001', DATE '2024-05-01', 'Interstellar', 2014, 1, CAST(NULL AS DATE) FROM dual UNION ALL
        SELECT '1000000002', DATE '2024-05-02', 'Todo sobre mi madre', 1999, 1, DATE '2024-05-05' FROM dual UNION ALL
        SELECT '1000000003', DATE '2024-05-03', 'El quinto elemento', 1997, 1, CAST(NULL AS DATE) FROM dual
    ) x
    JOIN cliente c  ON c.dni = x.dni
    JOIN renta r    ON r.cliente_id = c.cliente_id AND r.inicia = x.inicia
    JOIN pelicula p ON p.titulo = x.titulo AND p.anio = x.anio
    JOIN ejemplar e ON e.pelicula_id = p.pelicula_id AND e.numero = x.numero
) s
ON (er.renta_id = s.renta_id AND er.ejemplar_id = s.ejemplar_id)
WHEN NOT MATCHED THEN
    INSERT (renta_id, ejemplar_id, entrega) VALUES (s.renta_id, s.ejemplar_id, s.entrega);

-- Confirma de forma definitiva todos los datos cargados.
COMMIT;
