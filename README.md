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
├── logs/
│   └── <fecha>_ejecucion-completa/      # Registros de cada ejecución completa del proyecto
├── .gitignore
├── LICENSE
└── README.md
```

## Requisitos previos

- [XAMPP](https://www.apachefriends.org/) con el módulo **MySQL/MariaDB** habilitado.
- Cliente `mysql` disponible en la terminal (incluido en `xampp/mysql/bin`).
- Visual Studio Code con la extensión "MySQL" o "SQLTools" (opcional, para editar).
- MySQL Workbench (opcional, para la ingeniería inversa del modelo E-R).
- Git y una cuenta de GitHub (opcional, para control de versiones).

## Ejecución paso a paso en XAMPP MariaDB

### 1. Iniciar los servicios

Abre el **Panel de Control de XAMPP** y arranca el módulo **MySQL** (usa el motor
MariaDB internamente). Verifica que el estado quede en verde ("Running").

### 2. Verificar que el cliente `mysql` es accesible

**Windows (PowerShell):**

```powershell
# Agrega C:\xampp\mysql\bin al PATH si el comando no se reconoce.
mysql --version
```

**macOS / Linux (con XAMPP instalado en /Applications/XAMPP o /opt/lampp):**

```bash
/Applications/XAMPP/xamppfiles/bin/mysql --version
# o, si ya está en el PATH:
mysql --version
```

También puedes usar el script de diagnóstico incluido en el proyecto para confirmar
versión, puerto y estado del servidor antes de continuar:

```bash
mysql -u root -p < sql/mariadb/check-mariadb.sql
```

### 3. Ejecutar los scripts en orden

El orden de ejecución **es obligatorio**, porque cada script depende de que la
estructura o los datos del anterior ya existan (ver `docs/steps-create-project-database.pdf`).

```bash
# 1. Crea la base de datos, las tablas, las restricciones y el trigger de negocio.
mysql -u root -p < sql/mariadb/glob_gusters.sql

# 2. Carga los datos de prueba (nacionalidades, películas, actores, clientes, etc.).
mysql -u root -p < sql/mariadb/glob_gusters_insert.sql

# 3. Comandos DDL: crea/altera/elimina estructuras adicionales de ejemplo.
mysql -u root -p < sql/mariadb/commands/01_DDL.sql

# 4. Comandos DML: inserta, actualiza y elimina registros de ejemplo.
mysql -u root -p < sql/mariadb/commands/02_DML.sql

# 5. Comandos DQL: ejecuta consultas de verificación con JOIN y GROUP BY.
mysql -u root -p < sql/mariadb/commands/03_DQL.sql

# 6. Comandos VDL: crea y consulta vistas basadas en los datos ya cargados.
mysql -u root -p < sql/mariadb/commands/04_VDL.sql

# 7. Comandos DCL: crea usuarios y gestiona permisos sobre el esquema.
mysql -u root -p < sql/mariadb/commands/05_DCL.sql

# 8. Comandos TCL: demuestra transacciones con COMMIT, ROLLBACK y SAVEPOINT.
mysql -u root -p < sql/mariadb/commands/06_TCL.sql
```

> En Windows, reemplaza `mysql` por la ruta completa si el comando no está en el
> `PATH`, por ejemplo: `C:\xampp\mysql\bin\mysql -u root -p < sql\mariadb\glob_gusters.sql`.
> Por defecto, XAMPP configura el usuario `root` **sin contraseña**; en ese caso puedes
> omitir `-p` o presionar Enter cuando se solicite la contraseña.

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

```bash
mariadb -u root -p -h 127.0.0.1 -P 3306 --default-character-set=utf8mb4 \
    --force glob_gusters < tests/mariadb/glob_gusters_test.sql
```

El resultado es una tabla con una fila por prueba (`PASS`/`FAIL`) y un resumen final
con el total de pruebas aprobadas. El script no requiere procedimientos almacenados,
por lo que funciona incluso en instalaciones de XAMPP con la tabla de sistema
`mysql.proc` desactualizada (un problema común al reemplazar el `mysqld` incluido por
una versión más reciente sin ejecutar `mysql_upgrade`).

### Registros de ejecución

Cada corrida completa del proyecto (los ocho scripts más las pruebas de integridad)
queda documentada en `logs/<fecha>_ejecucion-completa/`, con un log por script y un
`00_resumen.log` que indica el código de salida de cada paso y cualquier incidencia
detectada y corregida durante esa ejecución.

## Cómo subir este proyecto a GitHub

```powershell
git init
git add .
git commit -m "Primer commit: modelo normalizado Glob-Gusters"
git branch -M main
git remote add origin https://github.com/<usuario>/glob-gusters-videoclub.git
git push -u origin main
```

## Licencia

Este proyecto se distribuye bajo licencia MIT. Véase el archivo [LICENSE](LICENSE).
