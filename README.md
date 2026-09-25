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

## Contenido del repositorio

```
glob-gusters-videoclub/
├── docs/
│   ├── relational-database.pdf          # Taller resuelto: diseño E-R de Glob-Gusters
│   ├── sql_scripts_commands.pdf         # Resumen de los grupos de comandos SQL (DDL/DML/DQL/DCL/TCL/VDL)
│   └── steps-create-project-database.pdf# Orden de ejecución recomendado del proyecto
├── sql/
│   └── mariadb/
│       ├── glob_gusters.sql             # DDL: base de datos, tablas, constraints y trigger
│       ├── glob_gusters_insert.sql      # DML: datos de prueba para todas las tablas
│       ├── check-mariadb.sql            # Script de diagnóstico del servidor MariaDB
│       └── commands/
│           ├── 01_DDL.sql               # CREATE / ALTER / DROP de ejemplo
│           ├── 02_DML.sql               # INSERT / UPDATE / DELETE de ejemplo
│           ├── 03_DQL.sql               # SELECT / JOIN / GROUP BY de ejemplo
│           ├── 04_VDL.sql               # CREATE VIEW / consulta / DROP VIEW de ejemplo
│           ├── 05_DCL.sql               # CREATE USER / GRANT / REVOKE de ejemplo
│           └── 06_TCL.sql               # START TRANSACTION / SAVEPOINT / COMMIT / ROLLBACK
├── tests/
│   └── mariadb/
│       └── glob_gusters_test.sql        # Pruebas de integridad integral del proyecto
├── .gitignore
├── LICENSE
└── README.md
```

## Requisitos previos

- [XAMPP](https://www.apachefriends.org/) con el módulo **MySQL/MariaDB** habilitado.
- Cliente `mariadb` (o `mysql`) disponible en la terminal. Ruta típica según sistema
  operativo:
  - **Windows:** `C:\xampp\mysql\bin\mariadb.exe`
  - **macOS:** `/Applications/XAMPP/xamppfiles/bin/mariadb`
  - **Linux:** `/opt/lampp/bin/mariadb`
- Visual Studio Code con la extensión "MySQL" o "SQLTools" (opcional, para editar).
- MySQL Workbench (opcional, para la ingeniería inversa del modelo E-R).
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

El resultado es una tabla con una fila por prueba (`PASS`/`FAIL`) y un resumen final
con el total de pruebas aprobadas. El script no requiere procedimientos almacenados,
por lo que funciona incluso en instalaciones de XAMPP con la tabla de sistema
`mysql.proc` desactualizada (un problema común al reemplazar el `mysqld` incluido por
una versión más reciente sin ejecutar `mysql_upgrade`).

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
