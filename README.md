# Glob-Gusters Video-Club · Base de Datos Relacional

Proyecto de base de datos relacional para la cadena de Video-Clubs **Glob-Gusters**,
desarrollado como material de apoyo para la asignatura de Base de Datos (Ingeniería de
Sistemas). El ejercicio original y su resolución paso a paso (identificación de
entidades, resolución de relaciones N-M, campos multivalorados y llaves) se encuentran
documentados en `docs/relational-database.pdf`.

Motor de base de datos: **MariaDB** sobre entorno **XAMPP**.

## Descripción del ejercicio

Glob-Gusters necesita una base de datos para gestionar el alquiler de películas. El
negocio maneja la siguiente información:

- Cada **película** tiene título, año, nacionalidad, productora y un director.
- En una película participan varios **actores** (con su nacionalidad y sexo), cada uno
  con un rol (Principal o Secundario).
- Cada película tiene uno o varios **ejemplares** físicos, diferenciados por número y
  con un estado de conservación.
- Los **clientes** (socios) alquilan ejemplares mediante **rentas**, que registran la
  fecha de inicio y de devolución.
- Un socio debe estar avalado por otro socio ya existente.
- Un socio puede tener, como máximo, **4 ejemplares** alquilados sin devolver al mismo
  tiempo (regla de negocio implementada mediante un `TRIGGER`).

### Modelo normalizado (Tercera Forma Normal — 3FN)

Para llegar a 3FN se extrajeron como catálogos independientes los campos que en el
enunciado original eran multivaluados o se repetían como texto libre
(`nacionalidad`, `productora`, `estado`), y se resolvieron las relaciones N-M mediante
tablas intermedias con llave subrogada autoincremental (`reparto`, `ejemplar_renta`).

| Tabla             | Llave primaria         | Descripción                                            |
|-------------------|-------------------------|---------------------------------------------------------|
| `nacionalidad`    | `Nacionalidad_ID`       | Catálogo de países de origen.                            |
| `productora`      | `Productora_ID`         | Catálogo de casas productoras.                           |
| `estado`          | `Estado_ID`             | Catálogo de estados de conservación de un ejemplar.      |
| `director`        | `Director_ID`           | Directores de películas.                                 |
| `pelicula`        | `Pelicula_ID`           | Catálogo de películas.                                   |
| `actor`           | `Actor_ID`               | Actores.                                                 |
| `reparto`         | `Reparto_ID`             | Resuelve la relación N-M película ↔ actor.               |
| `cliente`         | `Cliente_ID`             | Socios del video-club (con aval autorreferenciado).      |
| `ejemplar`        | `Ejemplar_ID`            | Copias físicas de cada película.                         |
| `renta`           | `Renta_ID`               | Encabezado de cada alquiler.                              |
| `ejemplar_renta`  | `Ejemplar_Renta_ID`      | Resuelve la relación N-M renta ↔ ejemplar.                |

El detalle completo de cada relación (tabla origen, campo FK, tabla destino, campo PK
y cardinalidad) está documentado como bloque de comentarios dentro de
`sql/mariadb/glob_gusters.sql`.

### Estructura de las tablas

PK = llave primaria, FK = llave foránea, UQ = restricción `UNIQUE`. Todas las llaves
foráneas usan `ON UPDATE CASCADE`; para `ON DELETE` ver «Reglas de negocio e integridad».

| Tabla | Columnas | Restricciones |
|---|---|---|
| `nacionalidad` | `Nacionalidad_ID`, `Nombre` VARCHAR(60) | PK; UQ `Nombre`. |
| `productora` | `Productora_ID`, `Nombre` VARCHAR(100) | PK; UQ `Nombre`. |
| `estado` | `Estado_ID`, `Nombre` VARCHAR(30) | PK; UQ `Nombre`. |
| `director` | `Director_ID`, `Nombre` VARCHAR(100), `Nacionalidad_ID` | PK; FK → `nacionalidad`. |
| `pelicula` | `Pelicula_ID`, `Titulo` VARCHAR(150), `Anio` YEAR, `Nacionalidad_ID`, `Productora_ID`, `Director_ID` | PK; UQ (`Titulo`, `Anio`); FK → `nacionalidad`, `productora`, `director`. |
| `actor` | `Actor_ID`, `Nombre` VARCHAR(100), `Nacionalidad_ID`, `Sexo` ENUM('M','F') | PK; FK → `nacionalidad`. |
| `reparto` | `Reparto_ID`, `Pelicula_ID`, `Actor_ID`, `Rol` ENUM('Principal','Secundario') | PK; UQ (`Pelicula_ID`, `Actor_ID`); FK → `pelicula`, `actor`. |
| `cliente` | `Cliente_ID`, `Dni` VARCHAR(15), `Nombre` VARCHAR(100), `Direccion` VARCHAR(150), `Telefono` VARCHAR(20), `Aval_Cliente_ID` (nulo) | PK; UQ `Dni`; FK `Aval_Cliente_ID` → `cliente` (autorreferencia). |
| `ejemplar` | `Ejemplar_ID`, `Numero`, `Pelicula_ID`, `Estado_ID` | PK; UQ (`Pelicula_ID`, `Numero`); FK → `pelicula`, `estado`. |
| `renta` | `Renta_ID`, `Cliente_ID`, `Inicia` DATE, `Termina` DATE (nulo) | PK; FK → `cliente`; `CHECK (Termina IS NULL OR Termina >= Inicia)`. |
| `ejemplar_renta` | `Ejemplar_Renta_ID`, `Renta_ID`, `Ejemplar_ID`, `Entrega` DATE (nulo) | PK; UQ (`Renta_ID`, `Ejemplar_ID`); FK → `renta`, `ejemplar`. |

Los scripts `01_DDL.sql` y su equivalente agregan después `cliente.Email`,
`pelicula.Duracion_Minutos`, amplían `cliente.Telefono` a `VARCHAR(25)` y crean el
índice `idx_pelicula_titulo`.

### Reglas de negocio e integridad

| Regla | Cómo se aplica |
|---|---|
| Un socio no puede ser su propio aval. | Triggers `trg_cliente_aval_diferente_insert` y `trg_cliente_aval_diferente_update` (MariaDB no permite `CHECK` sobre una columna `AUTO_INCREMENT`). |
| Un socio no puede tener más de 4 ejemplares sin devolver. | Trigger `trg_ejemplar_renta_max_4` en `ejemplar_renta`. |
| La fecha de devolución no puede ser anterior a la de inicio. | `CHECK` `chk_renta_fechas` en `renta`. |
| Un actor no se repite en la misma película; un ejemplar no se repite en la misma renta. | `UNIQUE` en `reparto` y `ejemplar_renta`. |
| No se puede borrar un registro que otro todavía necesita (una nacionalidad, productora, director, estado, socio o ejemplar en uso, ni un socio que avala a otro). | `ON DELETE RESTRICT` en las 9 llaves foráneas hacia `nacionalidad`, `productora`, `director`, `estado`, `cliente` (renta y aval) y `ejemplar` (en `ejemplar_renta`). |
| Al borrar un padre desaparecen sus detalles. | `ON DELETE CASCADE` en `reparto` (película y actor), `ejemplar` → `pelicula` y `ejemplar_renta` → `renta`. |

Los triggers rechazan la operación con `SIGNAL SQLSTATE '45000'` y un mensaje
descriptivo.

### Vistas y usuarios de ejemplo

| Objeto | Descripción |
|---|---|
| `v_ejemplares_detalle` | Ejemplares con título, año y estado de conservación. |
| `v_clientes_con_aval` | Socios con el nombre de quien los avala (`LEFT JOIN`, el aval puede ser nulo). |
| `glob_gusters_reportes`@`localhost` | Solo `SELECT` sobre `glob_gusters`. |
| `glob_gusters_mostrador`@`localhost` | `SELECT`, `INSERT` y `UPDATE`; el `DELETE` se revoca para proteger el historial de rentas. |

Las contraseñas de estos usuarios (`Reportes#2024` y `Mostrador#2024`) son solo de
ejemplo para un entorno de práctica; cámbialas en cualquier uso real.

### Datos de prueba

`glob_gusters_insert.sql` carga datos de muestra en todas las tablas:

| Tabla | Filas | Tabla | Filas |
|---|---|---|---|
| `nacionalidad` | 5 | `cliente` | 5 |
| `productora` | 4 | `ejemplar` | 6 |
| `estado` | 4 | `renta` | 4 |
| `director` | 4 | `ejemplar_renta` | 5 |
| `pelicula` | 4 | `reparto` | 5 |
| `actor` | 6 | | |

## Especificaciones del proyecto

| Aspecto | Detalle |
|---|---|
| Motor principal | MariaDB (XAMPP). Verificado con MariaDB 10.4.28. |
| Motor alternativo | Oracle Database 12c o superior (Oracle APEX), en `sql/oracle_apex/`. |
| Base de datos | `glob_gusters`, con juego de caracteres `utf8mb4` y collation `utf8mb4_general_ci`. |
| Motor de almacenamiento | InnoDB (necesario para llaves foráneas y transacciones). |
| Puerto de conexión | **3306** (en las variables de entorno `GLOB_GUSTERS_PORT` se puede cambiar). |
| Usuario por defecto | `root` sin contraseña (valor de XAMPP; ajústalo si tu servidor la exige). |
| Objetos | 11 tablas, 2 vistas, 3 triggers, 2 usuarios de ejemplo y 1 índice adicional. |
| Normalización | Tercera Forma Normal (3FN). |
| Pruebas | 23 pruebas automáticas en `tests/mariadb/glob_gusters_test.sql`. |
| Lenguajes de acceso | SQL, Python 3.9+ (PyMySQL / `mariadb`) y Java 17+ (JDBC). |

## Contenido del repositorio

```
glob-gusters-videoclub/
├── docs/
│   ├── MER.pdf / MER.png                # Modelo Entidad-Relación del proyecto
│   ├── glob_gusters_diccionario.pdf     # Diccionario de datos: tablas, columnas, tipos y llaves
│   ├── relational-database.pdf          # Taller resuelto: diseño E-R de Glob-Gusters
│   ├── sql_scripts_commands.pdf         # Resumen de los grupos de comandos SQL (DDL/DML/DQL/DCL/TCL/VDL)
│   └── steps-create-project-database.pdf# Orden de ejecución recomendado del proyecto
├── sql/
│   ├── mariadb/
│   │   ├── glob_gusters.sql             # DDL: base de datos, tablas, constraints y triggers
│   │   ├── glob_gusters_insert.sql      # DML: datos de prueba para todas las tablas
│   │   ├── check-mariadb.sql            # Script de diagnóstico del servidor MariaDB
│   │   └── commands/
│   │       ├── 01_DDL.sql               # CREATE / ALTER / DROP de ejemplo
│   │       ├── 02_DML.sql               # INSERT / UPDATE / DELETE de ejemplo
│   │       ├── 03_DQL.sql               # SELECT / JOIN / GROUP BY de ejemplo
│   │       ├── 04_VDL.sql               # CREATE VIEW / consulta / DROP VIEW de ejemplo
│   │       ├── 05_DCL.sql               # CREATE USER / GRANT / REVOKE de ejemplo
│   │       └── 06_TCL.sql               # START TRANSACTION / SAVEPOINT / COMMIT / ROLLBACK
│   └── oracle_apex/                     # Versión del proyecto para Oracle Database (APEX)
│       ├── 00_glob_gusters_oracle_apex.sql    # DDL: tablas, constraints y trigger compuesto
│       ├── 00b_glob_gusters_insert_oracle.sql # DML: datos de prueba (MERGE, repetible)
│       └── 01_DDL_oracle.sql ... 06_TCL_oracle.sql # Equivalentes Oracle de 01_DDL a 06_TCL
├── py/
│   ├── conexion.py                      # Conexión a MariaDB (PyMySQL) y funciones comunes
│   ├── conexion_mariabd.py              # Ejemplo mínimo con el conector oficial `mariadb`
│   ├── ddl.py / dml.py / dql.py         # Equivalentes en Python de 01_DDL, 02_DML y 03_DQL
│   ├── vdl.py / dcl.py / tcl.py         # Equivalentes en Python de 04_VDL, 05_DCL y 06_TCL
│   └── requirements.txt                 # Dependencias de Python (PyMySQL)
├── java/
│   ├── Conexion.java                    # Conexión a MariaDB (JDBC) y funciones comunes
│   ├── Ddl.java / Dml.java / Dql.java   # Equivalentes en Java de 01_DDL, 02_DML y 03_DQL
│   └── Vdl.java / Dcl.java / Tcl.java   # Equivalentes en Java de 04_VDL, 05_DCL y 06_TCL
├── tests/
│   └── mariadb/
│       └── glob_gusters_test.sql        # Pruebas de integridad integral del proyecto
├── logs/                                # Bitácoras de ejecución local (ignorada por Git)
├── .env.example                         # Plantilla de variables de entorno (se versiona)
├── .env                                 # Variables reales de conexión (local, ignorado por Git)
├── .gitignore
├── LICENSE
└── README.md
```

> `java/lib/` (driver JDBC) y `java/out/` (clases compiladas) se generan localmente y
> no se versionan. `logs/` guarda el resultado de cada ejecución completa: un
> `00_resumen.log` con el servidor, el comando y el resultado global, y un `.log` por script.

## Requisitos previos

- [XAMPP](https://www.apachefriends.org/) con el módulo **MySQL/MariaDB** habilitado.
- Cliente `mariadb` (o `mysql`) disponible en la terminal. Ruta típica según sistema
  operativo:
  - **Windows:** `C:\xampp\mysql\bin\mariadb.exe`
  - **macOS:** `/Applications/XAMPP/xamppfiles/bin/mariadb`
  - **Linux:** `/opt/lampp/bin/mariadb`
- Visual Studio Code con la extensión "MySQL" o "SQLTools" (opcional, para editar).
- MySQL Workbench (opcional, para la ingeniería inversa del modelo E-R).
- Python 3.9+ (opcional, para la carpeta `py/`).
- JDK 17 o superior (opcional, para la carpeta `java/`).
- Oracle Database 12c o superior, o un workspace de Oracle APEX (opcional, para `sql/oracle_apex/`).
- Git y una cuenta de GitHub (opcional, para control de versiones).

## Ejecución paso a paso en XAMPP MariaDB

Todos los ejemplos usan la misma conexión en los tres sistemas operativos
(`-u root -p -h 127.0.0.1 -P 3306 --default-character-set=utf8mb4`); sólo cambia la
ruta del binario y cómo el shell redirige la entrada estándar. Por defecto, XAMPP
configura el usuario `root` **sin contraseña**: cuando el comando pida `Enter password:`,
basta con presionar Enter.

### 1. Iniciar los servicios

**Windows y macOS:** abre el **Panel de Control de XAMPP** y arranca el módulo
**MySQL** (usa el motor MariaDB internamente). Verifica que el estado quede en verde
("Running").

**Linux:** inicia XAMPP desde la terminal con:

```bash
sudo /opt/lampp/lampp start
```

o abre el panel gráfico con `sudo /opt/lampp/manager-linux-x64.run` si está instalado.
Verifica que el módulo MySQL/MariaDB quede activo.

### 2. Verificar que el cliente `mariadb` es accesible

**Windows (PowerShell):**

```powershell
# Agrega C:\xampp\mysql\bin al PATH si el comando no se reconoce.
C:\xampp\mysql\bin\mariadb.exe --version
```

**macOS:**

```bash
/Applications/XAMPP/xamppfiles/bin/mariadb --version
# o, si ya agregaste esa ruta al PATH:
mariadb --version
```

**Linux:**

```bash
/opt/lampp/bin/mariadb --version
# o, si ya agregaste esa ruta al PATH:
mariadb --version
```

También puedes usar el script de diagnóstico incluido en el proyecto,
`sql/mariadb/check-mariadb.sql`, para confirmar de un vistazo:

- Versión, host y puerto del servidor.
- Sesión actual (usuario autenticado, base de datos seleccionada) y procesos
  activos.
- Estado del servidor (uptime, conexiones, consultas totales) y configuración
  relevante (charset, collation, `sql_mode`).
- Motores de almacenamiento disponibles (confirma que InnoDB, requerido por el
  proyecto, esté activo).
- Tablas, vistas y triggers ya creados en `glob_gusters`, y un resumen de filas
  por tabla.
- Usuarios del servidor y su estado de seguridad, sin exponer contraseñas.

Ajusta la ruta del binario según tu sistema operativo (como en el paso 3) y usa
siempre **`--force`**: el script está pensado para poder correrse en cualquier
momento (incluso antes de crear la base de datos del proyecto), y algunas de sus
secciones esperan condiciones que pueden no cumplirse todavía —por ejemplo, que
`glob_gusters` ya exista, o que el *event scheduler* esté activo—; sin `--force`
el cliente se detendría en la primera de ellas. El encabezado del script documenta
las tres limitaciones conocidas del entorno y por qué no son errores del proyecto.

```bash
mariadb -u root -p -h 127.0.0.1 -P 3306 --default-character-set=utf8mb4 \
    --force < sql/mariadb/check-mariadb.sql
```

### 3. Ejecutar los scripts en orden

El orden de ejecución **es obligatorio**, porque cada script depende de que la
estructura o los datos del anterior ya existan (ver `docs/steps-create-project-database.pdf`).

**Windows (PowerShell)** — PowerShell no admite `<` para redirigir un archivo a la
entrada estándar, por lo que se usa `Get-Content` junto con una función auxiliar:

```powershell
function Invoke-GlobGustersScript($Path) {
    Get-Content $Path | & "C:\xampp\mysql\bin\mariadb.exe" -u root -p -h 127.0.0.1 -P 3306 --default-character-set=utf8mb4
}

Invoke-GlobGustersScript "sql\mariadb\glob_gusters.sql"          # 1. Base de datos, tablas, constraints y trigger de negocio
Invoke-GlobGustersScript "sql\mariadb\glob_gusters_insert.sql"   # 2. Datos de prueba
Invoke-GlobGustersScript "sql\mariadb\commands\01_DDL.sql"       # 3. CREATE / ALTER / DROP de ejemplo
Invoke-GlobGustersScript "sql\mariadb\commands\02_DML.sql"       # 4. INSERT / UPDATE / DELETE de ejemplo
Invoke-GlobGustersScript "sql\mariadb\commands\03_DQL.sql"       # 5. SELECT / JOIN / GROUP BY de ejemplo
Invoke-GlobGustersScript "sql\mariadb\commands\04_VDL.sql"       # 6. CREATE VIEW / consulta / DROP VIEW de ejemplo
Invoke-GlobGustersScript "sql\mariadb\commands\05_DCL.sql"       # 7. CREATE USER / GRANT / REVOKE de ejemplo
Invoke-GlobGustersScript "sql\mariadb\commands\06_TCL.sql"       # 8. START TRANSACTION / SAVEPOINT / COMMIT / ROLLBACK
```

**macOS:**

```bash
run_mariadb() {
    /Applications/XAMPP/xamppfiles/bin/mariadb -u root -p -h 127.0.0.1 -P 3306 --default-character-set=utf8mb4 "$@"
}

run_mariadb < sql/mariadb/glob_gusters.sql          # 1. Base de datos, tablas, constraints y trigger de negocio
run_mariadb < sql/mariadb/glob_gusters_insert.sql   # 2. Datos de prueba
run_mariadb < sql/mariadb/commands/01_DDL.sql       # 3. CREATE / ALTER / DROP de ejemplo
run_mariadb < sql/mariadb/commands/02_DML.sql       # 4. INSERT / UPDATE / DELETE de ejemplo
run_mariadb < sql/mariadb/commands/03_DQL.sql       # 5. SELECT / JOIN / GROUP BY de ejemplo
run_mariadb < sql/mariadb/commands/04_VDL.sql       # 6. CREATE VIEW / consulta / DROP VIEW de ejemplo
run_mariadb < sql/mariadb/commands/05_DCL.sql       # 7. CREATE USER / GRANT / REVOKE de ejemplo
run_mariadb < sql/mariadb/commands/06_TCL.sql       # 8. START TRANSACTION / SAVEPOINT / COMMIT / ROLLBACK
```

**Linux:**

```bash
run_mariadb() {
    /opt/lampp/bin/mariadb -u root -p -h 127.0.0.1 -P 3306 --default-character-set=utf8mb4 "$@"
}

run_mariadb < sql/mariadb/glob_gusters.sql          # 1. Base de datos, tablas, constraints y trigger de negocio
run_mariadb < sql/mariadb/glob_gusters_insert.sql   # 2. Datos de prueba
run_mariadb < sql/mariadb/commands/01_DDL.sql       # 3. CREATE / ALTER / DROP de ejemplo
run_mariadb < sql/mariadb/commands/02_DML.sql       # 4. INSERT / UPDATE / DELETE de ejemplo
run_mariadb < sql/mariadb/commands/03_DQL.sql       # 5. SELECT / JOIN / GROUP BY de ejemplo
run_mariadb < sql/mariadb/commands/04_VDL.sql       # 6. CREATE VIEW / consulta / DROP VIEW de ejemplo
run_mariadb < sql/mariadb/commands/05_DCL.sql       # 7. CREATE USER / GRANT / REVOKE de ejemplo
run_mariadb < sql/mariadb/commands/06_TCL.sql       # 8. START TRANSACTION / SAVEPOINT / COMMIT / ROLLBACK
```

> Si prefieres usar `cmd.exe` en Windows en vez de PowerShell, la redirección `<`
> funciona igual que en macOS/Linux:
> `C:\xampp\mysql\bin\mariadb.exe -u root -p -h 127.0.0.1 -P 3306 --default-character-set=utf8mb4 < sql\mariadb\glob_gusters.sql`

#### Ejecución segura: se puede repetir y desordenar sin miedo

Todos los scripts del proyecto están diseñados para ejecutarse **varias veces y en
secuencias no lineales** sin generar errores ni datos duplicados:

- Toda `CREATE DATABASE`, `CREATE TABLE`, `CREATE TRIGGER`, `ADD COLUMN` y
  `CREATE INDEX` usa `IF [NOT] EXISTS`.
- `glob_gusters_insert.sql` localiza cada llave foránea por su nombre natural (país,
  título+año, DNI, etc.) en vez de un ID numérico fijo, y protege cada fila con
  `INSERT IGNORE` (tablas con `UNIQUE`) o `WHERE NOT EXISTS` (tablas sin `UNIQUE`
  natural, como `director`/`actor`, o con trigger de negocio, como `ejemplar_renta`).
- `02_DML.sql` y `06_TCL.sql` localizan sus registros por llave natural y verifican
  si el dato de ejemplo ya existe antes de insertarlo, para no acumular préstamos
  activos y terminar chocando con el trigger de máximo 4 ejemplares.
- `03_DQL.sql` y `04_VDL.sql` son de sólo lectura o usan `CREATE OR REPLACE VIEW`.
- `05_DCL.sql` usa `CREATE USER IF NOT EXISTS`; repetir el `GRANT`/`REVOKE` no falla.

Esto se validó ejecutando los 8 scripts tres veces seguidas sin recrear la base de
datos, y en una secuencia desordenada con repeticiones (`05 → 01 → 05 → insert →
06 → 06 → 02 → 02 → glob_gusters.sql → 04 → 03`): en ambos casos, cero errores y los
mismos conteos de filas en todas las tablas.

### 4. Verificar la instalación desde phpMyAdmin (opcional)

1. Abre `http://localhost/phpmyadmin` con XAMPP en ejecución.
2. Selecciona la base de datos `glob_gusters` en el panel izquierdo.
3. Confirma que existan las 11 tablas del modelo, las vistas `v_ejemplares_detalle` y
   `v_clientes_con_aval`, y que la pestaña **Triggers** muestre los tres disparadores
   de reglas de negocio:
   - `trg_ejemplar_renta_max_4` (en `ejemplar_renta`): máximo 4 ejemplares activos
     por socio.
   - `trg_cliente_aval_diferente_insert` y `trg_cliente_aval_diferente_update` (en
     `cliente`): un socio no puede ser su propio aval.

### 5. Ejecutar las pruebas de integridad

`tests/mariadb/glob_gusters_test.sql` verifica de punta a punta que el despliegue fue
correcto: existencia de las 11 tablas y las 2 vistas, datos cargados en cada tabla,
ausencia de registros huérfanos, cumplimiento de los tres triggers y del `CHECK` de
fechas de `renta`, consistencia de las vistas y permisos de los usuarios creados en
`05_DCL.sql`. Debe ejecutarse **con la bandera `--force`**, porque intencionalmente
provoca errores esperados (inserciones que el motor debe rechazar) y necesita que la
conexión continúe después de cada uno para poder verificarlos y limpiarlos:

**Windows (PowerShell):**

```powershell
Get-Content tests\mariadb\glob_gusters_test.sql | & "C:\xampp\mysql\bin\mariadb.exe" -u root -p -h 127.0.0.1 -P 3306 --default-character-set=utf8mb4 --force glob_gusters
```

**macOS:**

```bash
/Applications/XAMPP/xamppfiles/bin/mariadb -u root -p -h 127.0.0.1 -P 3306 --default-character-set=utf8mb4 \
    --force glob_gusters < tests/mariadb/glob_gusters_test.sql
```

**Linux:**

```bash
/opt/lampp/bin/mariadb -u root -p -h 127.0.0.1 -P 3306 --default-character-set=utf8mb4 \
    --force glob_gusters < tests/mariadb/glob_gusters_test.sql
```

Las 23 pruebas cubren: existencia de las 11 tablas y las 2 vistas, datos en cada tabla,
registros huérfanos, los tres triggers, el `CHECK` de fechas, la coherencia de las vistas
y los permisos de los usuarios de ejemplo.

El resultado es una tabla con una fila por prueba (`PASS`/`FAIL`) y un resumen final
con el total de pruebas aprobadas. El script no requiere procedimientos almacenados,
por lo que funciona incluso en instalaciones de XAMPP con la tabla de sistema
`mysql.proc` desactualizada (un problema común al reemplazar el `mysqld` incluido por
una versión más reciente sin ejecutar `mysql_upgrade`).

## Versión para Oracle APEX

La carpeta `sql/oracle_apex/` contiene la conversión del proyecto a **Oracle Database**
(requiere 12c o superior) para ejecutarla en *SQL Workshop → SQL Scripts* de Oracle APEX.
El modelo es el mismo de 3FN; los cambios principales respecto a MariaDB son:

- `AUTO_INCREMENT` pasa a `GENERATED BY DEFAULT ON NULL AS IDENTITY`; `VARCHAR` a
  `VARCHAR2`; `YEAR` y `ENUM` se reemplazan por `NUMBER(4)` y `VARCHAR2` con `CHECK`.
- El trigger «no ser su propio aval» se sustituye por un `CHECK`, y el de «máximo 4
  ejemplares» es un `COMPOUND TRIGGER` (evita el error ORA-04091, tabla mutante).
- Oracle anterior a 23ai no admite `IF [NOT] EXISTS`: las sentencias se envuelven en
  bloques PL/SQL que consultan el diccionario, y los `INSERT` son `MERGE`, de modo que
  los scripts siguen siendo repetibles.
- `05_DCL_oracle.sql` informa con `DBMS_OUTPUT` (sin fallar) si el esquema del workspace
  no tiene privilegios para `CREATE USER`.

Orden de ejecución (obligatorio):

```
00_glob_gusters_oracle_apex.sql  →  00b_glob_gusters_insert_oracle.sql  →
01_DDL_oracle.sql → 02_DML_oracle.sql → 03_DQL_oracle.sql →
04_VDL_oracle.sql → 05_DCL_oracle.sql → 06_TCL_oracle.sql
```

## Configuración de la conexión (`.env`)

Python y Java leen los datos de conexión de variables de entorno. Para no escribirlas en
la terminal cada vez, ambos cargan automáticamente el archivo `.env` de la **raíz del
proyecto**. Ese archivo es local y está en `.gitignore`, así que tu contraseña no se
sube a GitHub; la plantilla versionada es `.env.example`:

```bash
cp .env.example .env      # y edita GLOB_GUSTERS_PASSWORD si tu root tiene contraseña
```

| Variable | Valor por defecto | Uso |
|---|---|---|
| `GLOB_GUSTERS_HOST` | `localhost` | Servidor MariaDB. |
| `GLOB_GUSTERS_PORT` | `3306` | Puerto de conexión. |
| `GLOB_GUSTERS_USER` | `root` | Usuario. |
| `GLOB_GUSTERS_PASSWORD` | *(vacía)* | Contraseña del usuario. |
| `GLOB_GUSTERS_DB` | `glob_gusters` | Base de datos. |
| `GLOB_GUSTERS_PASS_REPORTES` | `Reportes#2024` | Clave de la cuenta de ejemplo que crean `dcl.py` / `Dcl`. |
| `GLOB_GUSTERS_PASS_MOSTRADOR` | `Mostrador#2024` | Ídem para la cuenta de mostrador. |

Formato: una línea `CLAVE=valor` por variable; se ignoran las líneas vacías y las que
empiezan con `#`. Una variable ya definida en el sistema (`export GLOB_GUSTERS_PORT=...`)
tiene prioridad sobre el `.env`. Si no hay `.env`, se usan los valores por defecto.

## Conexión y consultas desde Python

La carpeta `py/` conecta la base `glob_gusters` a Python y reproduce, con los mismos
datos de ejemplo, cada grupo de comandos SQL de `sql/mariadb/commands/`. La conexión
equivale a `mysql -u root -p -h localhost -P 3306 -D glob_gusters`.

**Requisitos:** Python 3.9+ y el servidor MariaDB de XAMPP en ejecución, con la base ya
creada (pasos 1 a 3 de la sección anterior).

```bash
pip install -r py/requirements.txt
python py/conexion.py      # prueba de conexión: versión, base y cuenta
```

Los valores por defecto son los de XAMPP (`localhost`, `3306`, `root` sin contraseña,
base `glob_gusters`). Se pueden cambiar sin editar el código con las variables de entorno
`GLOB_GUSTERS_HOST`, `GLOB_GUSTERS_PORT`, `GLOB_GUSTERS_USER`, `GLOB_GUSTERS_PASSWORD` y
`GLOB_GUSTERS_DB`. `dcl.py` también acepta `GLOB_GUSTERS_PASS_REPORTES` y
`GLOB_GUSTERS_PASS_MOSTRADOR` para las contraseñas de las cuentas de ejemplo.

| Script | Equivale a | Qué hace |
|---|---|---|
| `py/ddl.py` | `01_DDL.sql` | CREATE / ALTER / CREATE INDEX / DROP con `IF [NOT] EXISTS`. |
| `py/dml.py` | `02_DML.sql` | INSERT / UPDATE / DELETE con parámetros y llaves naturales. |
| `py/dql.py` | `03_DQL.sql` | SELECT, JOIN y GROUP BY; `python py/dql.py <nombre>` ejecuta una sola consulta. |
| `py/vdl.py` | `04_VDL.sql` | Crea y consulta las dos vistas; `--drop` las elimina. |
| `py/dcl.py` | `05_DCL.sql` | CREATE USER / GRANT / REVOKE / SHOW GRANTS (requiere cuenta administrativa). |
| `py/tcl.py` | `06_TCL.sql` | Transacción con SAVEPOINT y COMMIT, y otra descartada con ROLLBACK. |

`py/conexion_mariabd.py` es un ejemplo aparte, mínimo, con el conector oficial `mariadb`
(`pip install mariadb`, no incluido en `requirements.txt`): lista la tabla `nacionalidad`.
Tiene el usuario, la clave y el puerto escritos en el código; edítalos si tu servidor difiere.

Se ejecutan en el mismo orden que los scripts SQL (`ddl` → `dml` → `dql` → `vdl` →
`dcl` → `tcl`) y, como ellos, se pueden repetir sin errores ni datos duplicados. Las
sentencias usan parámetros (`%s`) y nunca concatenan valores dentro del SQL.

## Conexión y consultas desde Java

La carpeta `java/` hace lo mismo que `py/` pero con **JDBC**: una clase `Conexion` y un
programa por grupo de comandos SQL. La conexión equivale a
`mysql -u root -p -h localhost -P 3306 -D glob_gusters`.

**Requisitos:** JDK 17 o superior (usa *text blocks* y `record`) y el servidor MariaDB
de XAMPP en ejecución, con la base ya creada (pasos 1 a 3 de arriba). El driver
[MariaDB Connector/J](https://mariadb.com/kb/en/about-mariadb-connector-j/) no se
versiona; se descarga a `java/lib/`:

```bash
cd java
mkdir -p lib
curl -L -o lib/mariadb-java-client-3.5.3.jar \
  https://repo1.maven.org/maven2/org/mariadb/jdbc/mariadb-java-client/3.5.3/mariadb-java-client-3.5.3.jar
javac -encoding UTF-8 -d out *.java
java -cp "out:lib/*" Conexion      # prueba de conexión: versión, base y cuenta
```

En Windows el separador del *classpath* es `;`: `java -cp "out;lib/*" Conexion`.

Los valores por defecto son los de XAMPP (`localhost`, `3306`, `root` sin contraseña,
base `glob_gusters`) y se cambian con las mismas variables de entorno de Python:
`GLOB_GUSTERS_HOST`, `GLOB_GUSTERS_PORT`, `GLOB_GUSTERS_USER`,
`GLOB_GUSTERS_PASSWORD` y `GLOB_GUSTERS_DB`. `Dcl` también acepta
`GLOB_GUSTERS_PASS_REPORTES` y `GLOB_GUSTERS_PASS_MOSTRADOR`.

| Clase | Equivale a | Qué hace |
|---|---|---|
| `Ddl` | `01_DDL.sql` | CREATE / ALTER / CREATE INDEX / DROP con `IF [NOT] EXISTS`. |
| `Dml` | `02_DML.sql` | INSERT / UPDATE / DELETE con parámetros y llaves naturales. |
| `Dql` | `03_DQL.sql` | SELECT, JOIN y GROUP BY; `java -cp "out:lib/*" Dql <nombre>` ejecuta una sola consulta. |
| `Vdl` | `04_VDL.sql` | Crea y consulta las dos vistas; `--drop` las elimina. |
| `Dcl` | `05_DCL.sql` | CREATE USER / GRANT / REVOKE / SHOW GRANTS (requiere cuenta administrativa). |
| `Tcl` | `06_TCL.sql` | Transacción con SAVEPOINT y COMMIT, y otra descartada con ROLLBACK. |

Se ejecutan en el mismo orden que los scripts SQL (`Ddl` → `Dml` → `Dql` → `Vdl` →
`Dcl` → `Tcl`) y, como ellos, se pueden repetir sin errores ni datos duplicados. Las
sentencias usan parámetros (`?`) con `PreparedStatement` y nunca concatenan valores
dentro del SQL.

## Cómo subir este proyecto a GitHub

Estos comandos de `git` son idénticos en Windows (PowerShell o cmd.exe), macOS y
Linux:

```bash
git init
git add .
git commit -m "Primer commit: modelo normalizado Glob-Gusters"
git branch -M main
git remote add origin https://github.com/<usuario>/glob-gusters-videoclub.git
git push -u origin main
```

## Protección de la rama `main`

La rama `main` de este repositorio tiene activada la protección de rama de GitHub,
con la siguiente configuración:

| Regla | Estado |
|---|---|
| Requiere Pull Request para fusionar cambios | ✅ Activado |
| Aprobaciones mínimas por PR | **1** |
| Se aplica también al propietario/administrador | ❌ Desactivado |
| Permite `force-push` a `main` | ❌ Bloqueado |
| Permite eliminar la rama `main` | ❌ Bloqueado |

En la práctica, esto significa:

- **El propietario del repositorio** conserva permiso para hacer `git push` directo
  a `main`, sin necesidad de abrir un Pull Request.
- **Cualquier otro colaborador** (sin permisos de administrador) que quiera
  modificar el proyecto o agregar una nueva funcionalidad debe crear una rama,
  subir sus cambios y abrir un Pull Request contra `main`; ese PR necesita al menos
  **una aprobación humana** antes de poder fusionarse.

Esta configuración se administra desde **Settings → Branches → Branch protection
rules** en GitHub, o mediante la API:

```bash
gh api repos/<usuario>/glob-gusters-videoclub/branches/main/protection
```

## Licencia

Este proyecto se distribuye bajo licencia MIT. Véase el archivo [LICENSE](LICENSE).
