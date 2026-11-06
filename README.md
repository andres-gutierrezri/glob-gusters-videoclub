# Glob-Gusters Video-Club · Base de Datos Relacional

Proyecto de base de datos relacional para la cadena de Video-Clubs **Glob-Gusters**,
desarrollado como material de apoyo para la asignatura de Base de Datos (Ingeniería de
Sistemas). El ejercicio original y su resolución paso a paso (identificación de
entidades, resolución de relaciones N-M, campos multivalorados y llaves) se encuentran
documentados en `docs/relational-database.pdf`.

Motor de base de datos: **MariaDB** sobre entorno **XAMPP**.

<!-- indice:inicio -->
## Índice

- [Descripción del ejercicio](#descripción-del-ejercicio)
  - [Modelo normalizado (Tercera Forma Normal — 3FN)](#modelo-normalizado-tercera-forma-normal--3fn)
  - [Estructura de las tablas](#estructura-de-las-tablas)
  - [Reglas de negocio e integridad](#reglas-de-negocio-e-integridad)
  - [Vistas y usuarios de ejemplo](#vistas-y-usuarios-de-ejemplo)
  - [Datos de prueba](#datos-de-prueba)
- [Especificaciones del proyecto](#especificaciones-del-proyecto)
- [Contenido del repositorio](#contenido-del-repositorio)
- [Requisitos previos](#requisitos-previos)
- [Dependencias requeridas](#dependencias-requeridas)
  - [Instalación de las dependencias, por sistema operativo](#instalación-de-las-dependencias-por-sistema-operativo)
- [Guía de ejecución por sistema operativo](#guía-de-ejecución-por-sistema-operativo)
  - [1. Archivos SQL (MariaDB)](#1-archivos-sql-mariadb)
  - [2. Diagnóstico del servidor (`check-mariadb`)](#2-diagnóstico-del-servidor-check-mariadb)
  - [3. Pruebas de integridad (`tests/`)](#3-pruebas-de-integridad-tests)
  - [4. Python](#4-python)
  - [5. Java](#5-java)
  - [6. Windows CMD (Símbolo del sistema)](#6-windows-cmd-símbolo-del-sistema)
    - [6.1 Archivos SQL](#61-archivos-sql)
    - [6.2 Diagnóstico y pruebas](#62-diagnóstico-y-pruebas)
    - [6.3 Python](#63-python)
    - [6.4 Java](#64-java)
    - [6.5 Si las tildes o la `ñ` se ven mal en la consola](#65-si-las-tildes-o-la-ñ-se-ven-mal-en-la-consola)
  - [7. Oracle APEX (opcional)](#7-oracle-apex-opcional)
  - [Probar la creación desde cero sin tocar tu base](#probar-la-creación-desde-cero-sin-tocar-tu-base)
  - [Tildes y `ñ` en la terminal](#tildes-y-ñ-en-la-terminal)
  - [Errores frecuentes](#errores-frecuentes)
- [Scripts de shell (`shell/`)](#scripts-de-shell-shell)
  - [Antes de empezar](#antes-de-empezar)
  - [Linux y macOS (Bash)](#linux-y-macos-bash)
  - [Windows (PowerShell)](#windows-powershell)
  - [Windows (CMD)](#windows-cmd)
  - [Qué hacen y qué no](#qué-hacen-y-qué-no)
- [Última verificación de ejecución](#última-verificación-de-ejecución)
- [Ejecución paso a paso en XAMPP MariaDB](#ejecución-paso-a-paso-en-xampp-mariadb)
  - [1. Iniciar los servicios](#1-iniciar-los-servicios)
  - [2. Verificar que el cliente `mariadb` es accesible](#2-verificar-que-el-cliente-mariadb-es-accesible)
  - [3. Ejecutar los scripts en orden](#3-ejecutar-los-scripts-en-orden)
    - [Ejecución segura: se puede repetir y desordenar sin miedo](#ejecución-segura-se-puede-repetir-y-desordenar-sin-miedo)
  - [4. Verificar la instalación desde phpMyAdmin (opcional)](#4-verificar-la-instalación-desde-phpmyadmin-opcional)
  - [5. Ejecutar las pruebas de integridad](#5-ejecutar-las-pruebas-de-integridad)
- [Versión para Oracle APEX](#versión-para-oracle-apex)
- [Configuración de la conexión (`.env`)](#configuración-de-la-conexión-env)
- [Conexión y consultas desde Python](#conexión-y-consultas-desde-python)
- [Conexión y consultas desde Java](#conexión-y-consultas-desde-java)
- [Documentación detallada de cada archivo](#documentación-detallada-de-cada-archivo)
  - [Archivos de la raíz](#archivos-de-la-raíz)
    - [`.env.example` — plantilla de configuración](#envexample--plantilla-de-configuración)
    - [`.env` — configuración real y local](#env--configuración-real-y-local)
    - [`.gitignore` — archivos que Git no versiona](#gitignore--archivos-que-git-no-versiona)
    - [`requirements.txt` — dependencias de Python](#requirementstxt--dependencias-de-python)
    - [`LICENSE`](#license)
    - [`README.md`](#readmemd)
  - [Carpeta `docs/`](#carpeta-docs)
  - [Carpeta `sql/mariadb/`](#carpeta-sqlmariadb)
    - [`glob_gusters.sql` — esquema completo (DDL)](#glob_gusterssql--esquema-completo-ddl)
    - [`glob_gusters_insert.sql` — datos de prueba (DML)](#glob_gusters_insertsql--datos-de-prueba-dml)
    - [`check-mariadb.sql` — diagnóstico del servidor (solo lectura)](#check-mariadbsql--diagnóstico-del-servidor-solo-lectura)
    - [`check-mariadb.sh` — lanzador con la configuración del `.env`](#check-mariadbsh--lanzador-con-la-configuración-del-env)
    - [`commands/01_DDL.sql` a `06_TCL.sql` — ejemplos por grupo de comandos SQL](#commands01_ddlsql-a-06_tclsql--ejemplos-por-grupo-de-comandos-sql)
  - [Carpeta `sql/oracle_apex/`](#carpeta-sqloracle_apex)
    - [`00_glob_gusters_oracle_apex.sql` — esquema](#00_glob_gusters_oracle_apexsql--esquema)
    - [`00b_glob_gusters_insert_oracle.sql` — datos de prueba](#00b_glob_gusters_insert_oraclesql--datos-de-prueba)
    - [`01_DDL_oracle.sql` a `06_TCL_oracle.sql`](#01_ddl_oraclesql-a-06_tcl_oraclesql)
  - [Carpeta `py/`](#carpeta-py)
    - [`conexion.py` — módulo base](#conexionpy--módulo-base)
    - [`conexion_mariabd.py`](#conexion_mariabdpy)
    - [`ddl.py`, `dml.py`, `dql.py`, `vdl.py`, `dcl.py`, `tcl.py`](#ddlpy-dmlpy-dqlpy-vdlpy-dclpy-tclpy)
  - [Carpeta `java/`](#carpeta-java)
    - [`Conexion.java` — clase base](#conexionjava--clase-base)
    - [`Ddl.java`, `Dml.java`, `Dql.java`, `Vdl.java`, `Dcl.java`, `Tcl.java`](#ddljava-dmljava-dqljava-vdljava-dcljava-tcljava)
  - [Carpeta `tests/`](#carpeta-tests)
    - [`tests/mariadb/glob_gusters_test.sql` — pruebas de integridad](#testsmariadbglob_gusters_testsql--pruebas-de-integridad)
  - [Flujo completo de ejecución y dependencias entre archivos](#flujo-completo-de-ejecución-y-dependencias-entre-archivos)
- [Cómo subir este proyecto a GitHub](#cómo-subir-este-proyecto-a-github)
- [Protección de la rama `main`](#protección-de-la-rama-main)
- [Licencia](#licencia)
<!-- indice:fin -->

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
| Un socio no puede tener más de 4 ejemplares sin devolver. | Triggers `trg_ejemplar_renta_max_4` (INSERT) y `trg_ejemplar_renta_max_4_update` (UPDATE) en `ejemplar_renta`; solo cuentan los renglones con `Entrega` nula. |
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
| Objetos | 11 tablas, 2 vistas, 4 triggers, 2 usuarios de ejemplo y 1 índice adicional. |
| Normalización | Tercera Forma Normal (3FN). |
| Pruebas | 25 pruebas automáticas en `tests/mariadb/glob_gusters_test.sql`. |
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
│   │   ├── check-mariadb.sh             # Lanzador: ejecuta el diagnóstico con la configuración del .env
│   │   ├── check-mariadb.ps1            # Lanzador equivalente para Windows PowerShell
│   │   ├── check-mariadb.cmd            # Lanzador equivalente para Windows CMD
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
│   └── vdl.py / dcl.py / tcl.py         # Equivalentes en Python de 04_VDL, 05_DCL y 06_TCL
├── java/
│   ├── Conexion.java                    # Conexión a MariaDB (JDBC) y funciones comunes
│   ├── Ddl.java / Dml.java / Dql.java   # Equivalentes en Java de 01_DDL, 02_DML y 03_DQL
│   └── Vdl.java / Dcl.java / Tcl.java   # Equivalentes en Java de 04_VDL, 05_DCL y 06_TCL
├── shell/                               # Lanzadores que ejecutan SQL, Python y Java con un comando
│   ├── bash/                            # Linux y macOS: lib.sh, configurar-utf8.sh, ejecutar-sql/python/java/todo.sh
│   ├── powershell/                      # Windows PowerShell: lib.ps1, configurar-utf8.ps1, ejecutar-sql/python/java/todo.ps1
│   └── cmd/                             # Windows CMD: lib.cmd, configurar-utf8.cmd, ejecutar-sql/python/java/todo.cmd
├── tests/
│   └── mariadb/
│       └── glob_gusters_test.sql        # Pruebas de integridad integral del proyecto
├── logs/                                # Bitácoras de ejecución local (ignorada por Git)
├── requirements.txt                     # Dependencias de Python (PyMySQL)
├── .env.example                         # Plantilla de variables de entorno (se versiona)
├── .env                                 # Variables reales de conexión (local, ignorado por Git)
├── .gitattributes                       # Fin de línea fijo: LF en .sh, CRLF en .cmd y .ps1
├── .gitignore
├── LICENSE
└── README.md
```

> `.venv/` (entorno virtual de Python), `java/lib/` (driver JDBC) y `java/out/` (clases
> compiladas) se generan localmente y no se versionan. `logs/` guarda el resultado de cada ejecución completa: un
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

El detalle de versiones y cómo instalarlo en Windows, macOS y Linux está en
[Dependencias requeridas](#dependencias-requeridas); los comandos para ejecutar SQL, Python
y Java en cada sistema, en [Guía de ejecución por sistema operativo](#guía-de-ejecución-por-sistema-operativo).

## Dependencias requeridas

Resumen de todo lo que hay que tener instalado, por componente. Cada parte del proyecto es
independiente: para usar solo SQL basta MariaDB y su cliente; Python y Java son opcionales.

| Componente | Versión | Para qué se usa | Obligatorio para |
|---|---|---|---|
| **MariaDB** (servidor) | **10.2.1 o superior** (verificado con 10.4.28, la de XAMPP) | Aloja la base `glob_gusters`. Los scripts usan `CHECK`, `IF NOT EXISTS` en `ADD COLUMN`/`CREATE INDEX`/`CREATE TRIGGER` y `CREATE OR REPLACE VIEW`. | Todo |
| Cliente `mariadb` (o `mysql`) | El que trae el servidor | Ejecuta los archivos `.sql` desde la terminal. | SQL, pruebas y diagnóstico |
| **Python** | **3.9 o superior** (probado con 3.13) | Scripts de `py/`. | Python |
| `PyMySQL` | `>=1.1` (`requirements.txt`) | Conector que usan todos los scripts de `py/` a través de `conexion.py`. | Python |
| `mariadb` (paquete de pip) | `>=1.1` (`requirements.txt`) | Conector oficial; solo lo usa `py/conexion_mariabd.py`. | Solo ese ejemplo |
| MariaDB Connector/C | **3.3.1 o superior** (librería del sistema, no es un paquete de pip) | Lo necesita el paquete `mariadb` para instalarse. El de XAMPP (3.1.x) es demasiado antiguo. | Solo `mariadb` |
| **JDK** | **17 o superior** (probado con 26) | Compila y ejecuta `java/` (usa *text blocks* y `record`). | Java |
| MariaDB Connector/J | **3.5.3** o superior de la serie 3.x (`java/lib/mariadb-java-client-<versión>.jar`, no se versiona; los lanzadores `ejecutar-java` lo actualizan solo; la 3.5.11 se probó con los 7 programas de `java/`) | Driver JDBC. | Java |
| Git Bash (solo Windows) | Cualquiera reciente | Ejecutar `sql/mariadb/check-mariadb.sh`. | Solo ese lanzador |
| Oracle Database / APEX | 12c o superior | Scripts de `sql/oracle_apex/`. | Solo la versión Oracle |

> **MariaDB, no MySQL de Oracle.** Los scripts usan sintaxis propia de MariaDB (por ejemplo
> `ADD COLUMN IF NOT EXISTS` y `CREATE INDEX IF NOT EXISTS`) que MySQL de Oracle no
> admite. Si en tu equipo conviven ambos servidores, comprueba que apuntas al de MariaDB
> (puerto 3306 en XAMPP). Los programas de Python, Java y el lanzador del diagnóstico
> conectan por TCP a `127.0.0.1` justamente para no caer en el socket de otro servidor.

### Instalación de las dependencias, por sistema operativo

Los comandos de **macOS** están comprobados en este proyecto. Los de **Windows** y
**Linux** usan las herramientas estándar de cada sistema pero no se ejecutaron en esta
máquina.

| Dependencia | Windows (PowerShell) | macOS | Linux (Debian/Ubuntu; en Fedora usa `dnf`) |
|---|---|---|---|
| MariaDB + cliente | Instala [XAMPP](https://www.apachefriends.org/) y arranca **MySQL**. Cliente: `C:\xampp\mysql\bin\mariadb.exe` | XAMPP, o `brew install mariadb`. Cliente: `/Applications/XAMPP/xamppfiles/bin/mariadb` | XAMPP (`/opt/lampp/bin/mariadb`), o `sudo apt install mariadb-server mariadb-client` |
| Python 3.9+ | `winget install Python.Python.3.13` | `brew install python` | `sudo apt install python3 python3-venv python3-pip` |
| Connector/C (solo para `mariadb`) | Instálalo desde [mariadb.com/downloads/connectors](https://mariadb.com/downloads/connectors/) si `pip` intenta compilar el paquete | `brew install mariadb-connector-c` | `sudo apt install libmariadb-dev build-essential python3-dev` (Fedora: `sudo dnf install mariadb-connector-c-devel gcc python3-devel`) |
| JDK 17+ | `winget install EclipseAdoptium.Temurin.17.JDK` | `brew install openjdk@17` | `sudo apt install openjdk-17-jdk` |
| Driver JDBC | Ver «Java» en la guía de ejecución | Ver «Java» en la guía de ejecución | Ver «Java» en la guía de ejecución |

Para comprobar las versiones instaladas:

```bash
mariadb --version      # o: mysql --version
python3 --version      # Windows: python --version
javac -version
```

## Guía de ejecución por sistema operativo

Esta guía reúne, para **Windows (PowerShell y CMD)**, **macOS** y **Linux**, cómo ejecutar los
archivos SQL, el diagnóstico, las pruebas, Python y Java. Los pasos 1 a 5 usan PowerShell
en Windows; el paso 6 es la guía completa para **CMD** (Símbolo del sistema). Todas las
rutas son relativas a la **raíz del proyecto** (la carpeta que contiene `README.md`).

> ¿Prefieres no copiar comandos? Los lanzadores de [`shell/`](#scripts-de-shell-shell) ejecutan
> todo esto con un solo comando en Windows, macOS y Linux.

Convenciones usadas en los comandos:

| Sistema | Cliente MariaDB (`$MARIADB`) | Si `root` tiene contraseña |
|---|---|---|
| Windows | `C:\xampp\mysql\bin\mariadb.exe` | Agrega `-p` al comando (la pide), o define antes `$env:MYSQL_PWD = "tu_clave"` |
| macOS | `/Applications/XAMPP/xamppfiles/bin/mariadb` | Agrega `-p`, o `export MYSQL_PWD='tu_clave'` |
| Linux | `/opt/lampp/bin/mariadb` (o `mariadb` si lo instalaste con el sistema) | Agrega `-p`, o `export MYSQL_PWD='tu_clave'` |

Antes de empezar, asegúrate de que el servidor MariaDB está en marcha: en Windows y macOS,
módulo **MySQL** del Panel de XAMPP en verde; en Linux, `sudo /opt/lampp/lampp start`
(o `sudo systemctl start mariadb` si es una instalación del sistema).

### 1. Archivos SQL (MariaDB)

Se ejecutan **en este orden** (cada uno depende del anterior):
`glob_gusters.sql` → `glob_gusters_insert.sql` → `commands/01_DDL.sql` → `02_DML.sql` →
`03_DQL.sql` → `04_VDL.sql` → `05_DCL.sql` → `06_TCL.sql`. Son repetibles.

**Windows (PowerShell).** Se usa la orden `source` del propio cliente, que lee el archivo
directamente: evita los problemas de codificación (tildes, `ñ`) de canalizar texto por
PowerShell.

```powershell
$MARIADB = "C:\xampp\mysql\bin\mariadb.exe"
$Scripts = @(
    "sql/mariadb/glob_gusters.sql",
    "sql/mariadb/glob_gusters_insert.sql",
    "sql/mariadb/commands/01_DDL.sql",
    "sql/mariadb/commands/02_DML.sql",
    "sql/mariadb/commands/03_DQL.sql",
    "sql/mariadb/commands/04_VDL.sql",
    "sql/mariadb/commands/05_DCL.sql",
    "sql/mariadb/commands/06_TCL.sql"
)
foreach ($s in $Scripts) {
    Write-Host ">>> $s"
    & $MARIADB -u root -h 127.0.0.1 -P 3306 --default-character-set=utf8mb4 -e "source $s"
}
```

**macOS:**

```bash
MARIADB=/Applications/XAMPP/xamppfiles/bin/mariadb
for f in sql/mariadb/glob_gusters.sql sql/mariadb/glob_gusters_insert.sql \
         sql/mariadb/commands/01_DDL.sql sql/mariadb/commands/02_DML.sql \
         sql/mariadb/commands/03_DQL.sql sql/mariadb/commands/04_VDL.sql \
         sql/mariadb/commands/05_DCL.sql sql/mariadb/commands/06_TCL.sql; do
    echo ">>> $f"
    "$MARIADB" -u root -h 127.0.0.1 -P 3306 --default-character-set=utf8mb4 < "$f" || break
done
```

**Linux:** igual que macOS, cambiando la primera línea por
`MARIADB=/opt/lampp/bin/mariadb` (o `MARIADB=mariadb` si usas el MariaDB del sistema).

Si hubiera un error, el bucle de macOS/Linux se detiene en el primer archivo que falle
(`|| break`); el de PowerShell continúa, así que revisa los mensajes.

### 2. Diagnóstico del servidor (`check-mariadb`)

Es de solo lectura y se ejecuta con `--force`. Dos formas:

| Sistema | Con la configuración del `.env` | Directamente (usa la base `glob_gusters`) |
|---|---|---|
| macOS / Linux | `sh sql/mariadb/check-mariadb.sh` | `"$MARIADB" -u root -h 127.0.0.1 -P 3306 --default-character-set=utf8mb4 --force < sql/mariadb/check-mariadb.sql` |
| Windows | En **Git Bash**: `bash sql/mariadb/check-mariadb.sh` (si el cliente no está en el `PATH`, antes: `export MARIADB_BIN=/c/xampp/mysql/bin/mariadb.exe`) | `& $MARIADB -u root -h 127.0.0.1 -P 3306 --default-character-set=utf8mb4 --force -e "source sql/mariadb/check-mariadb.sql"` |

En Windows también existen `sql\mariadb\check-mariadb.ps1` (PowerShell, con
`powershell -ExecutionPolicy Bypass -File sql\mariadb\check-mariadb.ps1`) y
`sql\mariadb\check-mariadb.cmd` (CMD), que leen el `.env` sin necesitar Git Bash.

Para usar otra base desde la forma directa, agrega
`--init-command="SET @glob_gusters_db = 'mi_base'"`. En Windows el lanzador `.sh` necesita
Git Bash; la forma directa funciona en PowerShell sin nada más.

Es normal que aparezcan los errores 1577 (`event_scheduler` apagado) y 1558 (`mysql.proc`
desactualizada): son límites del entorno, descritos en el encabezado del script.

### 3. Pruebas de integridad (`tests/`)

Se ejecutan **después** de los ocho scripts, sobre la base `glob_gusters`. Los rechazos que
los triggers y el `CHECK` deben producir se capturan dentro del propio script (bloques
`BEGIN NOT ATOMIC` con un manejador de excepciones), así que **no se imprime ninguna línea
`ERROR`**; lo importante es la tabla final: **25 aprobadas, `PROYECTO OK`**. Los comandos
llevan `--force` por costumbre, pero ya no es obligatorio.

```powershell
# Windows (PowerShell)
& $MARIADB -u root -h 127.0.0.1 -P 3306 --default-character-set=utf8mb4 --force glob_gusters -e "source tests/mariadb/glob_gusters_test.sql"
```

```bash
# macOS y Linux
"$MARIADB" -u root -h 127.0.0.1 -P 3306 --default-character-set=utf8mb4 --force glob_gusters < tests/mariadb/glob_gusters_test.sql
```

### 4. Python

Requisitos: Python 3.9+, el servidor en marcha y la base ya creada (paso 1). Se trabaja
dentro de un entorno virtual (`.venv/`, no se versiona) con las dependencias de
`requirements.txt`.

**Windows (PowerShell):**

```powershell
python -m venv .venv
.venv\Scripts\Activate.ps1          # si PowerShell lo bloquea: Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned
pip install -r requirements.txt
Copy-Item .env.example .env         # una sola vez; edita GLOB_GUSTERS_PASSWORD si tu root tiene clave
python py\conexion.py
```

En `cmd.exe` la activación es `.venv\Scripts\activate.bat`.

**macOS y Linux:**

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env                # una sola vez; edita GLOB_GUSTERS_PASSWORD si tu root tiene clave
python py/conexion.py
```

> `requirements.txt` incluye `mariadb`, que necesita MariaDB Connector/C ≥ 3.3.1 instalado
> en el sistema (ver la tabla de instalación). Si solo quieres usar PyMySQL, comenta esa
> línea antes de instalar: todo `py/` funciona igual salvo `conexion_mariabd.py`. En macOS,
> si `pip` no encuentra el Connector/C instalado con Homebrew, ejecuta antes
> `export MARIADB_CONFIG=/opt/homebrew/opt/mariadb-connector-c/bin/mariadb_config`.

Con el entorno activo, ejecuta los scripts en el mismo orden que los SQL (en Windows usa
`\` en las rutas):

```bash
python py/ddl.py                  # 01_DDL
python py/dml.py                  # 02_DML
python py/dql.py                  # 03_DQL  (o: python py/dql.py disponibles)
python py/vdl.py                  # 04_VDL  (python py/vdl.py --drop elimina las vistas)
python py/dcl.py                  # 05_DCL  (requiere una cuenta administrativa)
python py/tcl.py                  # 06_TCL
python py/conexion_mariabd.py     # ejemplo con el conector oficial `mariadb`
```

Sin activar el entorno se puede llamar a su intérprete directamente:
`.venv/bin/python py/ddl.py` (macOS/Linux) o `.venv\Scripts\python.exe py\ddl.py` (Windows).
Para salir del entorno: `deactivate`.

### 5. Java

Requisitos: JDK 17+, el servidor en marcha y la base ya creada (paso 1). El driver JDBC se
descarga una sola vez a `java/lib/` (no se versiona). Los comandos se ejecutan desde la
carpeta `java/`; el programa encuentra el `.env` en la raíz del proyecto.

**Windows (PowerShell):**

```powershell
cd java
New-Item -ItemType Directory -Force lib | Out-Null
Invoke-WebRequest -Uri https://repo1.maven.org/maven2/org/mariadb/jdbc/mariadb-java-client/3.5.3/mariadb-java-client-3.5.3.jar -OutFile lib\mariadb-java-client-3.5.3.jar
javac -encoding UTF-8 -d out (Get-ChildItem *.java).Name
java -cp "out;lib/*" Conexion
```

**macOS y Linux:**

```bash
cd java
mkdir -p lib
curl -L -o lib/mariadb-java-client-3.5.3.jar \
  https://repo1.maven.org/maven2/org/mariadb/jdbc/mariadb-java-client/3.5.3/mariadb-java-client-3.5.3.jar
javac -encoding UTF-8 -d out *.java
java -cp "out:lib/*" Conexion
```

La única diferencia entre sistemas al ejecutar es el **separador del classpath**: `;` en
Windows (`"out;lib/*"`) y `:` en macOS/Linux (`"out:lib/*"`). Luego, en el mismo orden que los
SQL (aquí con la forma de macOS/Linux; en Windows cambia `:` por `;`):

```bash
java -cp "out:lib/*" Ddl          # 01_DDL
java -cp "out:lib/*" Dml          # 02_DML
java -cp "out:lib/*" Dql          # 03_DQL  (o: ... Dql disponibles)
java -cp "out:lib/*" Vdl          # 04_VDL  (... Vdl --drop elimina las vistas)
java -cp "out:lib/*" Dcl          # 05_DCL  (requiere una cuenta administrativa)
java -cp "out:lib/*" Tcl          # 06_TCL
```

### 6. Windows CMD (Símbolo del sistema)

Guía equivalente a las anteriores para quien trabaja en **`cmd.exe`** en lugar de PowerShell.
Abre el Símbolo del sistema (`Win + R`, escribe `cmd` y pulsa Enter), ve a la raíz del
proyecto con `cd` y sigue los pasos. Diferencias con PowerShell: las variables se definen con
`set` y se leen como `%VARIABLE%`, los comentarios son `REM`, la continuación de línea es `^`
y la redirección de archivos con `<` sí funciona (pasa el contenido tal cual, sin problemas de
tildes ni `ñ`).

> Los comandos de esta sección usan herramientas estándar de Windows pero **no se ejecutaron
> en esta máquina** (el proyecto se verificó en macOS). Si tu proyecto está en una carpeta
> con espacios, entrecomilla las rutas.

```bat
cd C:\ruta\a\glob-gusters-videoclub
```

#### 6.1 Archivos SQL

Los 8 scripts, en orden (el servidor de XAMPP debe estar en marcha, módulo **MySQL** en
verde). El comando `for` va en una sola instrucción; el `^` al final de línea la continúa:

```bat
set MARIADB=C:\xampp\mysql\bin\mariadb.exe

for %f in (sql\mariadb\glob_gusters.sql sql\mariadb\glob_gusters_insert.sql ^
           sql\mariadb\commands\01_DDL.sql sql\mariadb\commands\02_DML.sql ^
           sql\mariadb\commands\03_DQL.sql sql\mariadb\commands\04_VDL.sql ^
           sql\mariadb\commands\05_DCL.sql sql\mariadb\commands\06_TCL.sql) do ^
    @echo ^>^>^> %f & "%MARIADB%" -u root -h 127.0.0.1 -P 3306 --default-character-set=utf8mb4 < "%f"
```

- Si `root` tiene contraseña, define antes `set MYSQL_PWD=tu_clave` (sin comillas ni espacios
  alrededor del `=`) o agrega `-p` al comando (la pedirá en cada script).
- Si pones estos comandos dentro de un archivo `.bat`, duplica el signo de porcentaje:
  `%%f` en lugar de `%f`.
- Para ejecutar un solo archivo:
  `"%MARIADB%" -u root -h 127.0.0.1 -P 3306 --default-character-set=utf8mb4 < sql\mariadb\glob_gusters.sql`

#### 6.2 Diagnóstico y pruebas

```bat
REM Diagnóstico del servidor (solo lectura; usa la base glob_gusters)
"%MARIADB%" -u root -h 127.0.0.1 -P 3306 --default-character-set=utf8mb4 --force < sql\mariadb\check-mariadb.sql

REM Con otra base: agrega --init-command="SET @glob_gusters_db = 'mi_base'"

REM Pruebas de integridad (después de los 8 scripts; deben terminar con "PROYECTO OK")
"%MARIADB%" -u root -h 127.0.0.1 -P 3306 --default-character-set=utf8mb4 --force glob_gusters < tests\mariadb\glob_gusters_test.sql
```

El lanzador `sql\mariadb\check-mariadb.sh` no se puede usar en CMD (es un script `sh`); en
su lugar usa `sql\mariadb\check-mariadb.cmd`, que lee el `.env` igual que el `.sh`.

#### 6.3 Python

```bat
python -m venv .venv
.venv\Scripts\activate.bat
pip install -r requirements.txt
copy .env.example .env
REM (edita .env si tu root tiene contraseña: GLOB_GUSTERS_PASSWORD=...)

python py\conexion.py
python py\ddl.py
python py\dml.py
python py\dql.py
python py\vdl.py
python py\dcl.py
python py\tcl.py
python py\conexion_mariabd.py
```

- Al activar el entorno el indicador cambia a `(.venv) C:\...>`. Para salir: `deactivate`.
- Si `python` no se reconoce, prueba con `py -m venv .venv` (lanzador de Python para Windows).
- `copy .env.example .env` solo se hace una vez; si `.env` ya existe, pregunta antes de
  sobrescribirlo.
- `requirements.txt` incluye `mariadb`, que necesita MariaDB Connector/C (ver «Dependencias
  requeridas»); si solo usas PyMySQL, comenta esa línea antes de instalar.

#### 6.4 Java

```bat
cd java
mkdir lib
curl -L -o lib\mariadb-java-client-3.5.3.jar https://repo1.maven.org/maven2/org/mariadb/jdbc/mariadb-java-client/3.5.3/mariadb-java-client-3.5.3.jar
javac -encoding UTF-8 -d out *.java

java -cp "out;lib/*" Conexion
java -cp "out;lib/*" Ddl
java -cp "out;lib/*" Dml
java -cp "out;lib/*" Dql
java -cp "out;lib/*" Vdl
java -cp "out;lib/*" Dcl
java -cp "out;lib/*" Tcl
```

- El separador del classpath en Windows es `;` (y va entre comillas).
- `curl` viene incluido en Windows 10 (1803) y posteriores; si no lo tienes, descarga el JAR
  desde el enlace en el navegador y guárdalo en `java\lib\`.
- Para ejecutar una sola consulta: `java -cp "out;lib/*" Dql disponibles`; para eliminar las
  vistas: `java -cp "out;lib/*" Vdl --drop`.
- El programa encuentra el `.env` de la raíz estando dentro de `java\`.

#### 6.5 Si las tildes o la `ñ` se ven mal en la consola

La consola de CMD usa por defecto una página de códigos antigua. Antes de ejecutar los
programas, cambia a UTF-8 (solo afecta a esa ventana):

```bat
chcp 65001
```

Esto solo afecta a **cómo se muestra** el texto; los datos en la base están guardados
correctamente en `utf8mb4`. Los lanzadores de `shell\cmd\` ya lo hacen por ti; el resto de
capas está en [Tildes y `ñ` en la terminal](#tildes-y-ñ-en-la-terminal).

### 7. Oracle APEX (opcional)

No requiere instalar nada en el equipo: en *SQL Workshop → SQL Scripts* de tu workspace,
sube y ejecuta los archivos de `sql/oracle_apex/` en el orden indicado en la sección
«Versión para Oracle APEX». Con SQL*Plus o SQLcl (en cualquier sistema operativo) el
equivalente es `@sql/oracle_apex/00_glob_gusters_oracle_apex.sql`, etc.

### Probar la creación desde cero sin tocar tu base

Para comprobar que los scripts funcionan sobre un servidor vacío sin eliminar tu base
`glob_gusters`, levanta una segunda instancia de MariaDB con datos temporales (ejemplo de
macOS con XAMPP; ajusta las rutas en otros sistemas):

```bash
B=/Applications/XAMPP/xamppfiles; T=$(mktemp -d)
$B/bin/mysql_install_db --no-defaults --basedir=$B --datadir=$T/data \
    --auth-root-authentication-method=normal --skip-test-db
$B/sbin/mysqld --no-defaults --basedir=$B --datadir=$T/data --port=3399 \
    --bind-address=127.0.0.1 --socket=/tmp/gg3399.sock --pid-file=$T/mysqld.pid &
# ... ejecuta los scripts con -P 3399; Python, Java y check-mariadb.sh con GLOB_GUSTERS_PORT=3399 ...
$B/bin/mariadb-admin -u root -h 127.0.0.1 -P 3399 shutdown; rm -rf "$T" /tmp/gg3399.sock
```

El socket debe tener una ruta corta (el límite es de 103 caracteres), por eso se usa `/tmp`.

### Tildes y `ñ` en la terminal

Todo el proyecto trabaja en **UTF-8**: los archivos están guardados en UTF-8, la base usa
`utf8mb4` y cada capa fija la codificación para que las tildes y la `ñ` se lean y se
impriman igual en cualquier sistema.

| Capa | Qué se hace | Dónde |
|---|---|---|
| SQL (MariaDB) | `SET NAMES utf8mb4;` al inicio de cada script, además de `--default-character-set=utf8mb4` en los lanzadores: el texto se interpreta bien aunque el cliente no se lance con esa opción (phpMyAdmin, otro cliente). | `sql/mariadb/`, `commands/`, `tests/` |
| Python | `conexion.py` fuerza UTF-8 en `stdout` y `stderr` al importarse (`reconfigure`), así que `ddl.py`, `dml.py`, `dql.py`, `vdl.py`, `dcl.py`, `tcl.py` y `conexion_mariabd.py` imprimen UTF-8 aunque la salida se redirija a un archivo o a una bitácora. | `py/conexion.py` |
| Java | `Conexion.configurarSalida()` (llamada en la primera línea de cada `main`) fuerza UTF-8 en `System.out` y `System.err` cuando la salida no va a una terminal; los fuentes se compilan con `javac -encoding UTF-8`. | `java/Conexion.java` |
| PowerShell | `lib.ps1` pone la consola y `$OutputEncoding` en UTF-8 (sin BOM) y `PYTHONIOENCODING=utf-8`; los `.ps1` se guardan con BOM para que Windows PowerShell 5.1 lea bien sus tildes. | `shell/powershell/lib.ps1` |
| CMD | `lib.cmd` ejecuta `chcp 65001`. Los mensajes de los `.cmd` no llevan tildes a propósito (el intérprete de lotes las trata mal según la página de códigos); la salida de SQL, Python y Java sí sale con tildes. | `shell/cmd/lib.cmd` |
| Bash | Los lanzadores no necesitan ajustes: `bash` pasa los bytes tal cual y la terminal de Linux/macOS ya es UTF-8. Para la terminal interactiva está `configurar-utf8.sh`. | `shell/bash/` |

Con los lanzadores de `shell/` y `sql/mariadb/check-mariadb.*` no hay que hacer nada. Si
ejecutas los programas **a mano** en una consola de Windows, pon antes la consola en UTF-8
(solo afecta a esa ventana):

```powershell
# Windows PowerShell
[Console]::OutputEncoding = [Text.UTF8Encoding]::new($false); $OutputEncoding = [Console]::OutputEncoding
```

```bat
:: Windows CMD
chcp 65001
```

Para no escribirlo cada vez, la carpeta `shell/` trae un script por intérprete que deja
**la terminal actual** en UTF-8. Hay que cargarlo en esa terminal (con punto, `call` o
`source`); si se ejecuta sin eso, el cambio vale solo para el proceso del script y se pierde.

| Intérprete | Comando | Qué configura |
|---|---|---|
| PowerShell | `. .\shell\powershell\configurar-utf8.ps1` | Página de códigos 65001, `[Console]::OutputEncoding`/`InputEncoding`, `$OutputEncoding` y `PYTHONIOENCODING`. Con `-Persistente` agrega el bloque a `$PROFILE` (una sola vez) para todas las sesiones nuevas. |
| CMD | `call shell\cmd\configurar-utf8.cmd` | `chcp 65001` y `PYTHONIOENCODING`. |
| Bash | `source shell/bash/configurar-utf8.sh` | `LANG`/`LC_ALL` con un *locale* UTF-8 disponible (si ya lo es, no lo cambia) y `PYTHONIOENCODING`. |

Cada uno imprime una línea de prueba (`áéíóú ñ Ñ ü ¿¡ €`). En CMD y PowerShell la ventana
debe usar una fuente TrueType (Consolas, Cascadia Mono o Lucida Console). Para el cliente
`mariadb` a mano añade además `--default-character-set=utf8mb4`.

En macOS y Linux basta con una terminal y un *locale* UTF-8 (`echo $LANG` debe terminar en
`UTF-8`; si no, `export LANG=es_ES.UTF-8` o `export LANG=C.UTF-8`). En Oracle APEX y
SQL Developer la codificación la gestiona el navegador o el programa; con SQL\*Plus define
antes `NLS_LANG=AMERICAN_AMERICA.AL32UTF8`.

Esto solo afecta a **cómo se muestra** el texto: los datos se guardan correctamente en
`utf8mb4` en cualquier caso.

### Errores frecuentes

| Mensaje | Causa y solución |
|---|---|
| `Acceso denegado para 'root' en localhost:3306 sin contraseña` (Python/Java) o `Access denied for user 'root'@'localhost'` (SQL) | El usuario tiene contraseña y no se envió. Define `GLOB_GUSTERS_PASSWORD` en `.env` (Python/Java) o agrega `-p` (SQL). |
| `Acceso denegado para ...: el usuario o la contraseña son incorrectos` | Se envió una contraseña y el servidor la rechazó: revisa `GLOB_GUSTERS_USER` y `GLOB_GUSTERS_PASSWORD` en el `.env` o en las variables del sistema. Si además tienes MySQL de Oracle instalado, comprueba que conectas al servidor correcto (`-h 127.0.0.1 -P 3306`) y no a su socket. |
| `Got error 176 "Read page with wrong checksum" from storage engine Aria` (o «tabla dañada») | Una tabla del esquema `mysql` quedó dañada, normalmente por un cierre sucio de XAMPP. Los programas de `py/` y `java/` imprimen los pasos: `mysqlcheck -u root -p --check --databases mysql`, luego `--repair`; si no basta, con MySQL detenido `aria_chk --recover --force *.MAI` en `mysql\data\mysql`. Para evitarlo, detén MySQL con **Stop** antes de apagar el equipo. |
| `Unknown database 'glob_gusters'` / error 1049 | Aún no ejecutaste `glob_gusters.sql` (paso 1). |
| `requires MariaDB Connector/C >= 3.3.1` al hacer `pip install` | Falta el Connector/C del sistema (ver tabla de instalación) o comenta `mariadb` en `requirements.txt`. |
| `ModuleNotFoundError: No module named 'pymysql'` | No activaste el entorno virtual o no ejecutaste `pip install -r requirements.txt`. |
| `ClassNotFoundException` / `No suitable driver` en Java | Falta el JAR en `java/lib/`, o el separador del classpath es incorrecto para tu sistema (`;` Windows, `:` macOS/Linux). |
| `class file has wrong version` / `invalid source release` | El JDK es anterior a 17. |
| Tildes o `ñ` mal mostradas (`Ã³`, `Ã±`, `?`) | La terminal no está en UTF-8: ver [Tildes y `ñ` en la terminal](#tildes-y-ñ-en-la-terminal) (en Windows, `chcp 65001`). Ejecuta los SQL con `-e "source ..."` (no canalices con `Get-Content`) y `--default-character-set=utf8mb4`. |

## Scripts de shell (`shell/`)

La carpeta `shell/` reúne lanzadores listos para ejecutar **todo el proyecto con un solo
comando**: los 8 scripts SQL de MariaDB (más las pruebas y el diagnóstico), los programas de
Python y los de Java. Hay una versión por sistema operativo y cada una hace lo mismo:

| Sistema | Carpeta | Extensión | Intérprete |
|---|---|---|---|
| Linux y macOS | `shell/bash/` | `.sh` | Bash |
| Windows (PowerShell) | `shell/powershell/` | `.ps1` | Windows PowerShell 5.1 o PowerShell 7 |
| Windows (CMD) | `shell/cmd/` | `.cmd` | `cmd.exe` |

| Lanzador | Qué ejecuta |
|---|---|
| `ejecutar-sql` | Primero muestra la versión del cliente y del servidor y avisa si el servidor es anterior a MariaDB 10.2.1 (no instala nada; sin conexión avisa y sigue). Luego los 8 scripts de `sql/mariadb/` en orden, luego `tests/mariadb/glob_gusters_test.sql` (25 pruebas) y el diagnóstico `check-mariadb`. Se detiene en el primer error de los 8 scripts. |
| `ejecutar-python` | Crea `.venv` si falta, actualiza `pip` (si no hay Internet avisa y sigue), instala `requirements.txt` y ejecuta `conexion`, `ddl`, `dml`, `dql`, `vdl`, `dcl`, `tcl` y `conexion_mariabd` de `py/`. |
| `ejecutar-java` | Primero actualiza el driver JDBC: consulta en Maven Central la última versión **3.x** de MariaDB Connector/J y, si `java/lib/` no la tiene, la descarga y borra las anteriores (sin Internet usa el que haya; si no hay ninguno, baja la 3.5.3). Solo avanza dentro de la serie 3.x: la 4.x exige TLS y no conecta con el MariaDB de XAMPP sin configurarlo. Luego compila `java/*.java` y ejecuta `Conexion`, `Ddl`, `Dml`, `Dql`, `Vdl`, `Dcl` y `Tcl`. |
| `ejecutar-todo` | Los tres anteriores, en ese orden, deteniéndose en el primer fallo. |
| `lib` | Funciones comunes (no se ejecuta directamente): lee el `.env`, localiza el cliente `mariadb` y define el orden de los scripts SQL. |

### Antes de empezar

1. Arranca el servidor MariaDB (módulo **MySQL** de XAMPP en verde).
2. Ten instalado lo que vayas a ejecutar: el cliente `mariadb` para SQL, Python 3.9+ para
   Python y JDK 17+ para Java (ver [Dependencias requeridas](#dependencias-requeridas)).
3. No hace falta crear el `.env` a mano: si no existe, `ejecutar-python` y `ejecutar-java` lo
   copian desde `.env.example`. Si tu usuario `root` **tiene contraseña**, escríbela en
   `GLOB_GUSTERS_PASSWORD` dentro del `.env` (o defínela como variable de entorno).
4. Los lanzadores se pueden llamar **desde cualquier carpeta**: ubican solos la raíz del
   proyecto.

Todos leen la conexión con la misma prioridad que Python y Java: variable de entorno del
sistema, luego `.env`, luego el valor por defecto (`127.0.0.1:3306`, usuario `root`, base
`glob_gusters`).

### Linux y macOS (Bash)

```bash
# Todo el proyecto
bash shell/bash/ejecutar-todo.sh

# Por partes
bash shell/bash/ejecutar-sql.sh
bash shell/bash/ejecutar-python.sh
bash shell/bash/ejecutar-java.sh
```

Opciones: `ejecutar-sql.sh --sin-pruebas --sin-diagnostico` y
`ejecutar-todo.sh --sin-python --sin-java`; `-h` muestra la ayuda de cada script. Los
archivos ya se versionan como ejecutables (`chmod +x`), así que también sirve
`./shell/bash/ejecutar-todo.sh`.

Si el cliente `mariadb` no está en el `PATH` (es lo habitual con XAMPP), indica su ruta:

```bash
# macOS (XAMPP)
MARIADB_BIN=/Applications/XAMPP/xamppfiles/bin/mariadb bash shell/bash/ejecutar-todo.sh
# Linux (XAMPP)
MARIADB_BIN=/opt/lampp/bin/mariadb bash shell/bash/ejecutar-todo.sh
```

### Windows (PowerShell)

```powershell
# Todo el proyecto
powershell -ExecutionPolicy Bypass -File shell\powershell\ejecutar-todo.ps1

# Por partes
powershell -ExecutionPolicy Bypass -File shell\powershell\ejecutar-sql.ps1
powershell -ExecutionPolicy Bypass -File shell\powershell\ejecutar-python.ps1
powershell -ExecutionPolicy Bypass -File shell\powershell\ejecutar-java.ps1
```

- `-ExecutionPolicy Bypass` solo vale para esa ejecución y evita el bloqueo de scripts de
  PowerShell. En PowerShell 7 se usa `pwsh` en lugar de `powershell`. Si prefieres no
  escribirlo, abre la sesión con `Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned`
  y llama a los scripts directamente: `.\shell\powershell\ejecutar-todo.ps1`.
- Opciones: `-SinPruebas` y `-SinDiagnostico` (`ejecutar-sql.ps1`), `-SinPython` y `-SinJava`
  (`ejecutar-todo.ps1`).
- Si `mariadb.exe` no está en el `PATH` y XAMPP no está en `C:\xampp`:
  `$env:MARIADB_BIN = "D:\xampp\mysql\bin\mariadb.exe"` antes de ejecutar.
- Si Windows marca los scripts como descargados de Internet: `Unblock-File shell\powershell\*.ps1`.

### Windows (CMD)

```bat
REM Todo el proyecto
shell\cmd\ejecutar-todo.cmd

REM Por partes
shell\cmd\ejecutar-sql.cmd
shell\cmd\ejecutar-python.cmd
shell\cmd\ejecutar-java.cmd
```

- Opciones: `--sin-pruebas` y `--sin-diagnostico` (`ejecutar-sql.cmd`), `--sin-python` y
  `--sin-java` (`ejecutar-todo.cmd`).
- Si `mariadb.exe` no está en el `PATH` y XAMPP no está en `C:\xampp`:
  `set MARIADB_BIN=D:\xampp\mysql\bin\mariadb.exe` antes de ejecutar.
- Los mensajes de los `.cmd` no llevan tildes a propósito: `cmd.exe` las muestra mal según la
  página de códigos. Los scripts activan UTF-8 (`chcp 65001`) solo para esa ventana.
- Una contraseña con caracteres especiales de CMD (`%`, `^`, `&`) puede interpretarse mal desde
  el `.env`; en ese caso usa los lanzadores de PowerShell.

### Qué hacen y qué no

- Los lanzadores solo **orquestan** los mismos comandos de la [Guía de ejecución](#guía-de-ejecución-por-sistema-operativo);
  no cambian ningún script SQL, Python ni Java. Son repetibles.
- El script `dcl` (SQL, Python y Java) crea cuentas de ejemplo y requiere un usuario con
  privilegios administrativos (el `root` de XAMPP los tiene).
- Si el paquete `mariadb` de pip no se puede instalar (falta MariaDB Connector/C), el lanzador de
  Python instala solo PyMySQL, omite `conexion_mariabd.py` con un aviso y termina bien.
- Los scripts de `sql/oracle_apex/` **no** se incluyen: requieren un Oracle Database o un workspace
  de APEX (ver [Versión para Oracle APEX](#versión-para-oracle-apex)).
- Código de salida: `0` si todo terminó bien, distinto de `0` en cuanto algo falla (útil para
  automatizar). Las pruebas de integridad ya no imprimen líneas `ERROR`; en el diagnóstico completo
  (comentado por defecto) sí pueden verse algunos errores 1558 (ver [Guía de ejecución](#guía-de-ejecución-por-sistema-operativo)).
- Verificación: ver [Última verificación de ejecución](#última-verificación-de-ejecución). Los
  lanzadores de **PowerShell** y **CMD** se ejecutaron en Windows 11 (25/25 pruebas) y los de
  **Bash** se verificaron antes en macOS.

## Última verificación de ejecución

Todo el proyecto se ejecutó de punta a punta el 2026-11-06 en el entorno siguiente, sobre una
instancia **nueva y vacía** de MariaDB (datos temporales, puerto 3399, sin tocar el servidor
habitual). Es un registro de lo comprobado, no una garantía para otros equipos.

| Elemento | Versión |
|---|---|
| Sistema operativo | Windows 11 Pro Education (10.0.26200) |
| Servidor | MariaDB 10.4.32 (binarios de XAMPP), puerto 3399 |
| Python | 3.13.1, con PyMySQL 1.2.3 y mariadb 1.1.14 en `.venv` |
| Java | JDK 23.0.2, MariaDB Connector/J 3.5.3 |

| Qué se ejecutó | Resultado |
|---|---|
| Los 8 scripts SQL de `sql/mariadb/` en orden (`shell/bash/ejecutar-sql.sh` en Git Bash) | Los 8 terminan sin errores. Quedan las 11 tablas, las 2 vistas, los **4 triggers** y las 2 cuentas de ejemplo. |
| `tests/mariadb/glob_gusters_test.sql` | **25 de 25 pruebas aprobadas, PROYECTO OK.** Los 4 rechazos esperados (auto-aval, quinto ejemplar, reapertura de una devolución y fechas inválidas) se capturan en el script: no imprime ninguna línea `ERROR` y cada prueba verifica el mensaje del rechazo. Reverificado sin `--force` (código 0, stderr vacío); con un trigger eliminado a propósito las pruebas 3 y 20 fallan y el veredicto pasa a `REVISAR FALLAS`. |
| `sql/mariadb/check-mariadb.sh`, `.ps1` y `.cmd` | Los tres imprimen solo la verificación de la conexión (`Conexión OK`) y sus parámetros. |
| `shell/powershell/ejecutar-todo.ps1` y `shell/cmd/ejecutar-todo.cmd` | Ambos terminan con código 0: SQL, pruebas, diagnóstico, los 8 programas de Python (incluido `conexion_mariabd.py`) y las 7 clases de Java. |
| `py/*.py` y `java/*` ejecutados a mano, sin variables de entorno y con la salida redirigida | Los 7 scripts de Python y las 7 clases de Java terminan con código 0 y escriben **UTF-8 válido**, con tildes y `ñ`, sin *mojibake* (`Ã³`, `Ã±`). |
| Estática | `py_compile` con `-W error` y `javac -encoding UTF-8` sin errores. |

Notas sobre lo que **no** quedó comprobado en esta corrida:

- Los lanzadores de Bash en Linux y macOS (se verificaron antes en macOS con MariaDB 10.4.28,
  cuando eran 23 pruebas y 3 triggers) y los comandos de la guía para esos sistemas.
- Los scripts de `sql/oracle_apex/` (no hay un Oracle disponible), incluido el
  `COMPOUND TRIGGER` modificado para `UPDATE`.
- La visualización en una consola interactiva con otra página de códigos (850/437): se
  comprobaron los bytes de salida, no el aspecto en pantalla.

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

**Con la configuración del `.env`:** un archivo SQL no puede leer el `.env`, así que el
lanzador `sql/mariadb/check-mariadb.sh` lo hace por él. Lee `GLOB_GUSTERS_HOST`,
`GLOB_GUSTERS_PORT`, `GLOB_GUSTERS_USER`, `GLOB_GUSTERS_PASSWORD` y `GLOB_GUSTERS_DB`
(el sistema tiene prioridad sobre el `.env`), se conecta con ellos —usa TCP aunque el host
sea `localhost`— y ya lleva `--force`. El nombre de la base llega al script SQL por la
variable de sesión `@glob_gusters_db`; si se ejecuta el `.sql` directamente se usa
`glob_gusters`.

```bash
sh sql/mariadb/check-mariadb.sh
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
   `v_clientes_con_aval`, y que la pestaña **Triggers** muestre los cuatro disparadores
   de reglas de negocio:
   - `trg_ejemplar_renta_max_4` y `trg_ejemplar_renta_max_4_update` (en
     `ejemplar_renta`): máximo 4 ejemplares sin devolver por socio.
   - `trg_cliente_aval_diferente_insert` y `trg_cliente_aval_diferente_update` (en
     `cliente`): un socio no puede ser su propio aval.

### 5. Ejecutar las pruebas de integridad

`tests/mariadb/glob_gusters_test.sql` verifica de punta a punta que el despliegue fue
correcto: existencia de las 11 tablas y las 2 vistas, datos cargados en cada tabla,
ausencia de registros huérfanos, cumplimiento de los cuatro triggers y del `CHECK` de
fechas de `renta`, consistencia de las vistas y permisos de los usuarios creados en
`05_DCL.sql`. Las operaciones que el motor debe rechazar se ejecutan dentro de un bloque
`BEGIN NOT ATOMIC` con un manejador que guarda el mensaje del rechazo, y cada prueba lo
comprueba; por eso la salida no trae líneas `ERROR`. Los comandos llevan `--force` como
precaución, pero ya no es obligatorio:

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

Las 25 pruebas cubren: existencia de las 11 tablas y las 2 vistas, datos en cada tabla,
registros huérfanos, los cuatro triggers, el `CHECK` de fechas, la coherencia de las vistas
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
python3 -m venv .venv                # crea el entorno virtual (una sola vez; .venv/ no se versiona)
source .venv/bin/activate            # Windows PowerShell: .venv\Scripts\Activate.ps1
pip install -r requirements.txt
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
(`mariadb` está en `requirements.txt`, pero necesita instalar antes en el sistema MariaDB Connector/C ≥ 3.3.1 —en macOS `brew install mariadb-connector-c`; el de XAMPP es más antiguo—): lista la tabla `nacionalidad`.
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

## Documentación detallada de cada archivo

Esta sección describe, archivo por archivo, qué hace cada uno y qué hace cada línea o
bloque de código. Los números de línea se evitan a propósito (cambian al editar): cada
elemento se identifica por su nombre, que se puede buscar en el archivo. Los propios
archivos de código también llevan comentarios línea por línea.

Todos los scripts de `sql/mariadb/` y `tests/mariadb/` empiezan (tras su encabezado) con
`SET NAMES utf8mb4;`, que fija la codificación de la sesión para las tildes y la `ñ`; no se
repite en cada tabla de descripciones. Ver [Tildes y `ñ` en la terminal](#tildes-y-ñ-en-la-terminal).

Índice: [raíz](#archivos-de-la-raíz) ·
[docs/](#carpeta-docs) ·
[sql/mariadb/](#carpeta-sqlmariadb) ·
[sql/oracle_apex/](#carpeta-sqloracle_apex) ·
[py/](#carpeta-py) ·
[java/](#carpeta-java) ·
[tests/](#carpeta-tests) ·
[flujo completo](#flujo-completo-de-ejecución-y-dependencias-entre-archivos)

### Archivos de la raíz

#### `.env.example` — plantilla de configuración

Archivo de ejemplo que se versiona. Sirve como plantilla: se copia a `.env` y se edita.
Todas las líneas que empiezan con `#` son comentarios; las demás son `CLAVE=valor`.

| Línea | Qué hace |
|---|---|
| Encabezado `# ====` | Explica que es un archivo de configuración de ejemplo/plantilla, cómo copiarlo (`cp .env.example .env`), quién lo lee, las reglas de formato y la prioridad de los valores (sistema > `.env` > valor por defecto del código). |
| `GLOB_GUSTERS_HOST=localhost` | Servidor de MariaDB. |
| `GLOB_GUSTERS_PORT=3306` | Puerto TCP de MariaDB (3306 es el de XAMPP). |
| `GLOB_GUSTERS_USER=root` | Usuario de la conexión; `root` es necesario para `dcl.py`/`Dcl.java`. |
| `GLOB_GUSTERS_PASSWORD=` | Contraseña; vacía = sin contraseña (valor de XAMPP). |
| `GLOB_GUSTERS_DB=glob_gusters` | Base de datos a la que se conecta. |
| `GLOB_GUSTERS_PASS_REPORTES=Reportes#2024` | Contraseña con la que se crea la cuenta `glob_gusters_reportes`. |
| `GLOB_GUSTERS_PASS_MOSTRADOR=Mostrador#2024` | Contraseña con la que se crea la cuenta `glob_gusters_mostrador`. |

#### `.env` — configuración real y local

Misma estructura y mismos valores que `.env.example`, pero es el archivo que realmente
leen `py/conexion.py` y `java/Conexion.java`. Está en `.gitignore`, así que no se sube a
Git: es el lugar para escribir contraseñas reales. Cada variable tiene el mismo
significado que en la tabla anterior.

#### `.gitignore` — archivos que Git no versiona

| Sección | Patrones | Qué excluye |
|---|---|---|
| Configuración y secretos | `.env`, `.env.*`, `!.env.example` | Variables reales de conexión; la excepción `!` mantiene versionada la plantilla. |
| Registros | `*.log`, `/logs/` | Bitácoras de ejecución. |
| SQL / MariaDB / XAMPP / Oracle | `*.ibd`, `*.frm`, `*.err`, `*.pid`, `ib_logfile*`, `ibdata*` | Archivos de datos que genera el servidor. |
| | `.mysql_history`, `.mariadb_history`, `.sqlplus_history` | Historiales de los clientes de consola. |
| | `*.dump`, `*.sql.gz`, `*.sql.zip`, `*.sql.bak` | Volcados y respaldos locales. |
| | `*.lst`, `*.trc`, `*.mwb.bak`, `*.mwbhistory/` | Temporales de Oracle y MySQL Workbench. |
| Python | `.venv/`, `venv/`, `env/` | Entorno virtual. |
| | `__pycache__/`, `*.py[cod]`, `*$py.class` | Código compilado. |
| | `.pytest_cache/`, `.mypy_cache/`, `.ruff_cache/`, `.cache/`, `.coverage`, `htmlcov/` | Cachés y cobertura. |
| | `build/`, `dist/`, `*.egg-info/`, `*.egg`, `pip-log.txt`, `pip-delete-this-directory.txt`, `.ipynb_checkpoints/` | Empaquetado, logs de pip y Jupyter. |
| Java | `java/out/`, `java/bin/`, `java/target/`, `java/build/`, `*.class` | Clases compiladas. |
| | `*.jar`, `*.war`, `*.ear`, `hs_err_pid*`, `replay_pid*` | Empaquetados y volcados de error de la JVM. |
| | `java/lib/` | Driver JDBC descargado (no se versiona). |
| | `.gradle/`, `.mvn/wrapper/maven-wrapper.jar`, `.idea/`, `*.iml`, `.classpath`, `.project`, `.settings/`, `.factorypath`, `nbproject/` | Gradle/Maven y configuración de IDEs. |
| Editores | `.vscode/`, `*.code-workspace` | Configuración de Visual Studio Code. |
| Sistema y temporales | `Thumbs.db`, `.DS_Store`, `*.bak`, `*.tmp`, `*.swp` | Basura del sistema operativo y de editores. |

#### `requirements.txt` — dependencias de Python

| Línea | Qué hace |
|---|---|
| Bloque de comentarios | Explica cómo crear el entorno virtual e instalar (`python3 -m venv .venv`, `source .venv/bin/activate`, `pip install -r requirements.txt`). |
| `PyMySQL>=1.1` | Conector MySQL/MariaDB en Python puro; lo usa `py/conexion.py` y, a través de él, todos los scripts de `py/`. |
| `mariadb>=1.1` | Conector oficial, solo para `py/conexion_mariabd.py`. Requiere MariaDB Connector/C ≥ 3.3.1 instalado en el sistema (no es un paquete de pip; en macOS `brew install mariadb-connector-c`); el de XAMPP (3.1.x) es más antiguo. Los comentarios del archivo explican cómo instalarlo; si no se necesita, se puede comentar la línea. |

#### `LICENSE`

Texto de la licencia MIT del proyecto: permite usar, copiar, modificar y distribuir el
software conservando el aviso de copyright, sin garantía.

#### `README.md`

Este documento: descripción del ejercicio, modelo de datos, reglas de negocio,
instrucciones de ejecución en Windows/macOS/Linux, configuración del `.env`, uso desde
Python y Java, y esta documentación por archivo.

### Carpeta `docs/`

Documentos de apoyo en PDF/imagen (no contienen código):

| Archivo | Contenido |
|---|---|
| `MER.pdf` / `MER.png` | Modelo Entidad-Relación del proyecto (el PNG es la misma imagen para verla sin visor de PDF). |
| `glob_gusters_diccionario.pdf` | Diccionario de datos: tablas, columnas, tipos y llaves. |
| `relational-database.pdf` | Taller resuelto: enunciado e identificación de entidades, relaciones N-M, campos multivaluados y llaves. |
| `sql_scripts_commands.pdf` | Resumen de los grupos de comandos SQL (DDL/DML/DQL/VDL/DCL/TCL) en que se basan los scripts `01` a `06`. |
| `steps-create-project-database.pdf` | Orden de ejecución recomendado de los scripts. |

### Carpeta `sql/mariadb/`

#### `glob_gusters.sql` — esquema completo (DDL)

Crea la base de datos, las 11 tablas, las restricciones y los 4 triggers. Es idempotente:
tablas y triggers del aval usan `IF NOT EXISTS`; los triggers del límite de 4 usan
`CREATE OR REPLACE TRIGGER`, así una base ya creada recibe su versión actual.

| Bloque | Qué hace |
|---|---|
| Encabezado | Autor, fecha, motor y explicación de la normalización: 1FN (atributos atómicos; `nacionalidad`, `productora` y `estado` salen como catálogos), 2FN (las llaves compuestas de `reparto` y `ejemplar_renta` se sustituyen por llave subrogada y la combinación pasa a `UNIQUE`) y 3FN (sin dependencias transitivas). |
| `CREATE DATABASE IF NOT EXISTS glob_gusters ... utf8mb4 / utf8mb4_general_ci` | Crea la base con soporte completo de UTF-8. |
| `-- DROP DATABASE ...` (comentada) | Borrado completo, comentado por seguridad. |
| `USE glob_gusters` | Selecciona el esquema para las sentencias siguientes. |
| Tabla de comentarios de relaciones | Lista cada FK: tabla origen, campo, tabla destino, campo y cardinalidad. |
| `nacionalidad` | `Nacionalidad_ID` (PK autoincremental), `Nombre` VARCHAR(60) con `UNIQUE`. |
| `productora` | `Productora_ID`, `Nombre` VARCHAR(100) con `UNIQUE`. |
| `estado` | `Estado_ID`, `Nombre` VARCHAR(30) con `UNIQUE` (Nuevo, Bueno, Regular, Dañado). |
| `director` | `Director_ID`, `Nombre`, `Nacionalidad_ID` → `nacionalidad` (`ON UPDATE CASCADE ON DELETE RESTRICT`). |
| `pelicula` | `Pelicula_ID`, `Titulo`, `Anio` (tipo `YEAR`), FK a `nacionalidad`, `productora` y `director` (todas `RESTRICT` al borrar); `UNIQUE (Titulo, Anio)`. |
| `actor` | `Actor_ID`, `Nombre`, `Nacionalidad_ID`, `Sexo ENUM('M','F')`. |
| `reparto` | Tabla puente película↔actor: `Reparto_ID`, `Pelicula_ID`, `Actor_ID`, `Rol ENUM('Principal','Secundario')`; `UNIQUE (Pelicula_ID, Actor_ID)`; FK con `ON DELETE CASCADE`. |
| `cliente` | `Cliente_ID`, `Dni` (`UNIQUE`), `Nombre`, `Direccion`, `Telefono` VARCHAR(20), `Aval_Cliente_ID` (nulo) con FK a `cliente` (autorreferencia, `RESTRICT`). El comentario explica por qué "no ser su propio aval" no es un `CHECK`: MariaDB prohíbe usar una columna `AUTO_INCREMENT` en un `CHECK`. |
| `ejemplar` | `Ejemplar_ID`, `Numero`, `Pelicula_ID` (`CASCADE`), `Estado_ID` (`RESTRICT`); `UNIQUE (Pelicula_ID, Numero)`. |
| `renta` | `Renta_ID`, `Cliente_ID` (`RESTRICT`), `Inicia` DATE, `Termina` DATE nulo; `CHECK chk_renta_fechas (Termina IS NULL OR Termina >= Inicia)`. |
| `ejemplar_renta` | Tabla puente renta↔ejemplar: `Ejemplar_Renta_ID`, `Renta_ID` (`CASCADE`), `Ejemplar_ID` (`RESTRICT`), `Entrega` DATE nulo (nulo = aún sin devolver); `UNIQUE (Renta_ID, Ejemplar_ID)`. |
| `DELIMITER $$ ... DELIMITER ;` | Cambia temporalmente el delimitador para poder escribir `;` dentro del cuerpo de un trigger. |
| `trg_cliente_aval_diferente_insert` / `_update` | `BEFORE INSERT/UPDATE` en `cliente`: si `Aval_Cliente_ID` no es nulo e igual a `Cliente_ID`, lanza `SIGNAL SQLSTATE '45000'` con el mensaje «Un cliente no puede ser su propio aval.» |
| `trg_ejemplar_renta_max_4` | `BEFORE INSERT` en `ejemplar_renta`: declara `ejemplares_activos`, cuenta con un `SELECT COUNT(*) INTO` los ejemplares con `Entrega IS NULL` de todas las rentas del cliente dueño de la renta nueva, y si ya son 4 o más lanza `SIGNAL` con «El cliente ya tiene 4 ejemplares alquilados sin devolver.» |

#### `glob_gusters_insert.sql` — datos de prueba (DML)

Inserta datos ficticios respetando el orden de las llaves foráneas. Es repetible: las FK
se resuelven con subconsultas por llave natural (nombre, título+año, DNI), nunca con IDs
fijos. Tablas con `UNIQUE` usan `INSERT IGNORE`; `director`, `actor`, `renta` y
`ejemplar_renta` usan `INSERT ... SELECT ... FROM DUAL WHERE NOT EXISTS` (en las dos
últimas porque `IGNORE` no evita que el trigger se dispare).

| Bloque | Datos que carga |
|---|---|
| `nacionalidad` | Estados Unidos, España, Reino Unido, Francia, México. |
| `productora` | M.G.M., Warner Bros., Universal Pictures, El Deseo. |
| `estado` | Nuevo, Bueno, Regular, Dañado. |
| `director` | Mervyn LeRoy (EE. UU.), Pedro Almodóvar (España), Christopher Nolan (Reino Unido), Luc Besson (Francia). |
| `pelicula` | Quo Vadis (1951), Todo sobre mi madre (1999), Interstellar (2014), El quinto elemento (1997), cada una con su nacionalidad, productora y director. |
| `actor` | Robert Taylor, Deborah Kerr, Cecilia Roth, Matthew McConaughey, Anne Hathaway, Milla Jovovich. |
| `reparto` | 6 filas: Taylor y Kerr (Quo Vadis, Principal), Roth (Todo sobre mi madre), McConaughey (Interstellar, Principal), Hathaway (Interstellar, Secundario), Jovovich (El quinto elemento). |
| `cliente` | 4 socios: Laura Gómez (`1000000001`, sin aval, socia fundadora), Carlos Pérez (`…02`, avalado por Laura), María Rodríguez (`…03`, avalada por Laura) y Andrés Torres (`…04`, avalado por Carlos). El aval se envuelve en una tabla derivada para evitar el `ERROR 1093`. |
| `ejemplar` | 6 copias: Quo Vadis #1 (Bueno) y #2 (Regular), Todo sobre mi madre #1 (Nuevo), Interstellar #1 (Nuevo) y #2 (Bueno), El quinto elemento #1 (Bueno). |
| `renta` | 3 rentas: Laura (2024-05-01, abierta), Carlos (2024-05-02 a 2024-05-05) y María (2024-05-03, abierta). |
| `ejemplar_renta` | 4 renglones: Laura se lleva Quo Vadis #1 e Interstellar #1 (sin devolver), Carlos Todo sobre mi madre #1 (devuelto el 2024-05-05) y María El quinto elemento #1 (sin devolver). |

> Los conteos de la tabla «Datos de prueba» de arriba (5 clientes, 5 en `reparto`, 4
> rentas, 5 en `ejemplar_renta`) corresponden al estado final tras ejecutar también
> `02_DML.sql` (agrega un socio y borra un reparto) y `06_TCL.sql` (agrega una renta con su
> ejemplar).

#### `check-mariadb.sql` — diagnóstico del servidor (solo lectura)

Todo son `SELECT`/`SHOW`: no modifica nada. Por defecto solo imprime la verificación de
la conexión y sus parámetros (versión, host, puerto, cuenta, base seleccionada, id de
conexión y juego de caracteres de la sesión); el diagnóstico completo sigue en el archivo,
comentado con `/* ... */`, y se reactiva quitando esos marcadores. Se ejecuta con `--force` porque algunas
secciones pueden fallar por limitaciones del entorno (descritas en su encabezado: base
inexistente, `event_scheduler` apagado y `mysql.proc` desactualizada).

| Sección | Sentencias | Qué muestra |
|---|---|---|
| 1. Identidad y versión | `SELECT VERSION()`; `SELECT @@version, @@version_comment, @@version_compile_machine, @@version_compile_os`; `SELECT @@hostname`; `SHOW VARIABLES LIKE 'port'` | Versión, compilación, host y puerto. |
| 2. Sesión | `SELECT CURRENT_USER()`; `SELECT DATABASE()`; `SHOW PROCESSLIST` | Cuenta autenticada, base activa y procesos. |
| 3. Estado | `SHOW STATUS LIKE 'Uptime'`, `'Threads_connected'`, `'Questions'`; `SHOW STATUS` | Tiempo encendido, clientes conectados, consultas atendidas y el estado completo. |
| 4. Configuración | `SHOW VARIABLES LIKE 'character_set%'`, `'collation%'`, `'sql_mode'`; `SHOW VARIABLES` | Juegos de caracteres, collations y modo SQL. |
| 5. Motores | `SHOW ENGINES` | Confirma que InnoDB está disponible. |
| 6. Usuarios | `SELECT host, user, plugin FROM mysql.user` | Cuentas sin exponer el hash de contraseña. |
| 7. Objetos del proyecto | `SHOW TABLES`, `SHOW FULL TABLES ... WHERE Table_type = 'VIEW'`, `SHOW TRIGGERS` y `SHOW EVENTS`, todos con `FROM` la base `@db` (armados con `CONCAT` y ejecutados con `PREPARE`/`EXECUTE`, porque `USE` no admite parámetros) | Tablas, vistas, triggers y eventos (se espera lista vacía). |
| 8. Estado del proyecto | consulta a `information_schema.schemata` y a `information_schema.tables`, filtradas por `@db` | Existencia de la base y filas aproximadas/tamaño en KB por tabla. |
| 9. Rutinas | `SHOW PROCEDURE STATUS`; `SHOW FUNCTION STATUS`; `SELECT * FROM information_schema.routines LIMIT 10` | Procedimientos y funciones (el proyecto no define ninguno). |

Al inicio ejecuta `SET @db = COALESCE(@glob_gusters_db, 'glob_gusters')`: el nombre de la
base sale de `@glob_gusters_db` (que define el lanzador a partir de `GLOB_GUSTERS_DB`) o,
si no existe, es `glob_gusters`.

#### `check-mariadb.sh` — lanzador con la configuración del `.env`

Script `sh` que ejecuta `check-mariadb.sql` con los datos de conexión del proyecto.

| Elemento | Qué hace |
|---|---|
| `RAIZ`, `ENV_ARCHIVO` | Calcula la raíz del proyecto desde la ubicación del script (funciona desde cualquier carpeta) y la ruta del `.env`. |
| `leer CLAVE DEFECTO` | Busca `CLAVE=valor` en el `.env` con `sed` (admite `export ` y comillas) y devuelve la última coincidencia o el valor por defecto. No usa `source` ni `eval`, así que no ejecuta nada del archivo. |
| `HOST`, `PORT`, `USUARIO`, `CLAVE`, `BASE` | Resuelven cada variable con la prioridad sistema > `.env` > defecto (`localhost`, `3306`, `root`, vacía, `glob_gusters`). |
| `[ "$HOST" = "localhost" ] && HOST=127.0.0.1` | Fuerza TCP: con `localhost` el cliente usaría el socket Unix, que puede ser de otro servidor, e ignoraría el puerto. |
| Búsqueda de `CLIENTE` | Usa `MARIADB_BIN` si está definida; si no, `mariadb` del `PATH`, las rutas de XAMPP en macOS/Linux o `mysql`. Sale con error si no encuentra ninguno. |
| `MYSQL_PWD` | Pasa la contraseña por variable de entorno (no aparece en la lista de procesos); si está vacía no se define y se conecta sin contraseña. |
| `BASE_SQL` | Escapa barras y comillas simples del nombre de la base para el literal SQL. |
| `exec "$CLIENTE" ... --force --init-command="SET @glob_gusters_db = '...'" < check-mariadb.sql` | Ejecuta el cliente con `--force` (las secciones que fallan por limitaciones conocidas no detienen el reporte), define `@glob_gusters_db` al conectar y envía el script SQL por la entrada estándar. |

#### `commands/01_DDL.sql` a `06_TCL.sql` — ejemplos por grupo de comandos SQL

Se ejecutan en orden después del esquema y de los datos. Todos son repetibles.

| Archivo | Sentencias, en orden | Qué hace |
|---|---|---|
| `01_DDL.sql` | `USE`; `CREATE TABLE IF NOT EXISTS tabla_prueba`; `ALTER TABLE cliente ADD COLUMN IF NOT EXISTS Email VARCHAR(120)`; `ALTER TABLE pelicula ADD COLUMN IF NOT EXISTS Duracion_Minutos SMALLINT UNSIGNED`; `ALTER TABLE cliente MODIFY COLUMN Telefono VARCHAR(25)`; `CREATE INDEX IF NOT EXISTS idx_pelicula_titulo`; `DROP TABLE IF EXISTS tabla_prueba` | Crea una tabla de prueba, agrega las columnas `Email` y `Duracion_Minutos`, amplía el teléfono, crea un índice por título y elimina la tabla de prueba. |
| `02_DML.sql` | `INSERT IGNORE INTO cliente` (Sofía Ramírez, DNI `1000000005`, avalada por Laura, con email); `UPDATE ejemplar` (Quo Vadis #2 pasa a «Dañado»); `UPDATE pelicula` (Interstellar dura 169 min); `DELETE r FROM reparto` (quita a Anne Hathaway de Interstellar) | Muestra INSERT, UPDATE y DELETE localizando registros por llave natural. |
| `03_DQL.sql` | 4 `SELECT` | (1) ejemplares disponibles (sin `Entrega` pendiente); (2) rentas activas con `JOIN` de 5 tablas; (3) películas por nacionalidad con `GROUP BY`; (4) ejemplares por estado con `GROUP BY`. Solo lectura. |
| `04_VDL.sql` | `CREATE OR REPLACE VIEW v_ejemplares_detalle` + su `SELECT`; `CREATE OR REPLACE VIEW v_clientes_con_aval` + su `SELECT`; dos `DROP VIEW IF EXISTS` comentados | Crea y consulta las dos vistas (la segunda con `LEFT JOIN` para conservar a los socios sin aval). |
| `05_DCL.sql` | `CREATE USER IF NOT EXISTS glob_gusters_reportes`; `GRANT SELECT`; `CREATE USER IF NOT EXISTS glob_gusters_mostrador`; `GRANT SELECT, INSERT, UPDATE`; `REVOKE DELETE`; `FLUSH PRIVILEGES`; dos `SHOW GRANTS` | Crea las dos cuentas de ejemplo, les concede permisos, revoca el borrado al mostrador y muestra los permisos resultantes. Requiere `root`. |
| `06_TCL.sql` | `SET @cliente_demo_tcl`, `@ejemplar_demo_tcl`, `@ya_existe_tcl`; `START TRANSACTION`; `INSERT INTO renta ... WHERE NOT @ya_existe_tcl`; `SAVEPOINT sp_renta_creada`; `INSERT INTO ejemplar_renta ... LAST_INSERT_ID()`; `COMMIT`; segunda transacción con `UPDATE cliente` y `ROLLBACK` | Registra una renta con su detalle de forma atómica (omitida si ya existe) y demuestra un `ROLLBACK` que no deja efectos. El `ROLLBACK TO SAVEPOINT` queda como ejemplo comentado. |

### Carpeta `sql/oracle_apex/`

Versión del proyecto para Oracle Database 12c o superior, para ejecutar en *SQL Workshop →
SQL Scripts* de APEX. Los nombres de columnas y tablas van en minúscula sin comillas
(Oracle los guarda en mayúscula).

#### `00_glob_gusters_oracle_apex.sql` — esquema

| Bloque | Qué hace |
|---|---|
| Encabezado | Resume los cambios respecto a MariaDB: sin `CREATE DATABASE`/`USE`; `AUTO_INCREMENT` → `GENERATED BY DEFAULT ON NULL AS IDENTITY`; `VARCHAR` → `VARCHAR2`; `YEAR` → `NUMBER(4)` con `CHECK`; `ENUM` → `VARCHAR2` con `CHECK ... IN`; sin `ON UPDATE CASCADE`; `ON DELETE RESTRICT` es el comportamiento por defecto; el trigger del aval se vuelve un `CHECK`. |
| Limpieza opcional (comentada) | Bloque PL/SQL que borra las 11 tablas con `DROP TABLE ... CASCADE CONSTRAINTS PURGE`. |
| 11 `CREATE TABLE` | Mismas tablas y relaciones que en MariaDB. Diferencias: `pelicula.anio` lleva `CHECK (anio BETWEEN 1888 AND 2100)`; `actor.sexo` y `reparto.rol` llevan `CHECK ... IN`; `cliente` lleva `chk_cliente_aval (aval_cliente_id IS NULL OR aval_cliente_id <> cliente_id)`; `ejemplar.numero` lleva `CHECK (numero >= 0)`; `renta` lleva `chk_renta_fechas`. |
| 10 `CREATE INDEX ix_...` | Oracle no indexa las llaves foráneas automáticamente; se crean índices sobre las FK que lo necesitan. |
| 11 `COMMENT ON TABLE` | Descripción de cada tabla en el diccionario de datos. |
| `trg_ejemplar_renta_max_4` | `COMPOUND TRIGGER ... FOR INSERT OR UPDATE OF entrega, renta_id ON ejemplar_renta`: en `AFTER EACH ROW` guarda en una colección (`g_renta_ids`) las rentas de los renglones que quedan sin devolver (`entrega` nula); en `AFTER STATEMENT` recorre esa colección, obtiene el cliente de cada renta, cuenta sus ejemplares con `entrega IS NULL` y, si son más de 4, lanza `RAISE_APPLICATION_ERROR(-20001, ...)`. Se hace así para evitar el error ORA-04091 (tabla mutante). |
| Verificación (comentada) | Dos consultas para comprobar que hay 11 tablas y el trigger en estado `VALID`. |

#### `00b_glob_gusters_insert_oracle.sql` — datos de prueba

Carga los mismos datos que `glob_gusters_insert.sql`, pero con `MERGE INTO ... USING (...)
WHEN NOT MATCHED THEN INSERT`: solo inserta lo que aún no existe, por lo que es repetible.
Las FK se resuelven uniendo (`JOIN`) con las tablas padre por su nombre.

#### `01_DDL_oracle.sql` a `06_TCL_oracle.sql`

Equivalentes Oracle de los scripts `01` a `06`.

| Archivo | Diferencias respecto a MariaDB |
|---|---|
| `01_DDL_oracle.sql` | Oracle no admite `IF [NOT] EXISTS` (antes de 23ai): cada `CREATE TABLE`, `ADD` de columna, `CREATE INDEX` y `DROP TABLE` va en un bloque PL/SQL que consulta `user_tables`, `user_tab_columns` o `user_indexes` y ejecuta con `EXECUTE IMMEDIATE`. El `MODIFY` del teléfono no repite `NOT NULL` (daría ORA-01442). Los comentarios de columna usan `COMMENT ON COLUMN`. |
| `02_DML_oracle.sql` | El `INSERT` del socio nuevo es un `MERGE` (solo inserta si el DNI no existe); `UPDATE` y `DELETE` usan subconsultas en vez de `JOIN`; termina con `COMMIT`. |
| `03_DQL_oracle.sql` | Mismas cuatro consultas; añade `ORDER BY` para resultados estables. |
| `04_VDL_oracle.sql` | `CREATE OR REPLACE VIEW` de las mismas dos vistas; los `DROP VIEW` quedan comentados porque no existe `IF EXISTS`. |
| `05_DCL_oracle.sql` | Un bloque PL/SQL con un procedimiento `ejecutar` (informa con `DBMS_OUTPUT` y continúa si faltan privilegios: códigos -1031, -1917, -1918) y una función `existe_usuario`. Crea `GLOB_GUSTERS_REPORTES` y `GLOB_GUSTERS_MOSTRADOR` solo si no existen, da `CREATE SESSION`, y recorre las tablas y vistas del modelo: `SELECT` para ambos, `INSERT, UPDATE` solo sobre tablas al mostrador, y `REVOKE DELETE` solo si estaba otorgado (evita ORA-01927). No hay `FLUSH PRIVILEGES`. Termina consultando `user_tab_privs_made`. |
| `06_TCL_oracle.sql` | Un bloque PL/SQL: variables `%TYPE` en vez de variables de sesión; `INSERT ... RETURNING renta_id INTO` en lugar de `LAST_INSERT_ID()`; `TRUNC(SYSDATE)` en lugar de `CURDATE()`; no hay `START TRANSACTION` (se abre con el primer DML); `SAVEPOINT`, `COMMIT`, y manejo de excepciones (`NO_DATA_FOUND` → mensaje -20010; `OTHERS` → `ROLLBACK` y `RAISE`). La segunda transacción hace un `UPDATE` y `ROLLBACK`. |

### Carpeta `py/`

Todos los scripts usan PyMySQL a través de `conexion.py`, con consultas parametrizadas
(`%s`). Se ejecutan desde la raíz con el entorno virtual activo, por ejemplo
`python py/ddl.py`.

#### `conexion.py` — módulo base

| Elemento | Qué hace |
|---|---|
| Docstring | Explica el módulo, el comando equivalente de consola y las variables de entorno. |
| `_salida_utf8()` | Se ejecuta al importar el módulo: fuerza UTF-8 (`reconfigure(encoding="utf-8", errors="replace")`) en `stdout` y `stderr` para que las tildes y la `ñ` salgan bien aunque la salida se redirija. Cubre todos los scripts de `py/`. |
| `principal(funcion, *args)` | Ejecuta `funcion(*args)` (todos los scripts de `py/` la usan en su bloque `__main__`). Si el servidor informa una tabla dañada (errores 1030, 144, 145, 1194, 1195) termina con los pasos de reparación (`explicar_tabla_danada`) en lugar del traceback; cualquier otro error se propaga igual. |
| `import os`, `sys`, `contextmanager`, `Path`, `pymysql`, `DictCursor` | Variables de entorno, bloques `with`, rutas portables, el conector y el cursor que devuelve diccionarios. |
| `_cargar_env(ruta)` | Si el `.env` existe, lo lee línea por línea; ignora vacías, comentarios y líneas sin `=`; quita el prefijo `export `; separa en el primer `=`; y usa `os.environ.setdefault` para no pisar variables ya definidas en el sistema (quita comillas del valor). |
| `_cargar_env(Path(__file__)...parent.parent / ".env")` | La ejecuta al importar el módulo, apuntando al `.env` de la raíz. |
| `CONFIG` | Diccionario de parámetros: `host` (`localhost`), `port` (entero, `3306`), `user` (`root`), `password` (vacía por defecto), `database` (`glob_gusters`), `charset` `utf8mb4` y `cursorclass` `DictCursor`. |
| `conectar(**cambios)` | Mezcla `CONFIG` con los cambios; normaliza la contraseña `None` a `""`; abre la conexión con `autocommit=False` y la bandera `CLIENT.FOUND_ROWS`, para que un `UPDATE` informe las filas que coinciden con el `WHERE` (igual que el driver JDBC de Java y el cliente de MariaDB) y las salidas de Python y Java sean idénticas. Ante `OperationalError` 1045 (acceso denegado) sale sin traza con un mensaje que indica usuario, host y puerto: «sin contraseña» (apunta a `GLOB_GUSTERS_PASSWORD` del `.env`) si no se envió clave, o «el usuario o la contraseña son incorrectos» (apunta a `GLOB_GUSTERS_USER` y `GLOB_GUSTERS_PASSWORD`) si se envió; nunca imprime la contraseña. Ante 1049 (base inexistente) sale pidiendo ejecutar los SQL de creación; cualquier otro error se relanza. |
| `conexion(**cambios)` | Context manager: entrega la conexión con `yield` y la cierra en `finally`. |
| `consultar(con, sql, params)` | Ejecuta un `SELECT`/`SHOW` y devuelve todas las filas como lista de diccionarios. |
| `ejecutar(con, sql, params)` | Ejecuta una escritura sin hacer commit y devuelve las filas afectadas. |
| `imprimir(titulo, filas)` | Imprime una tabla de texto: título, columnas de la primera fila, ancho de cada columna (el mayor entre nombre y valores), encabezado, separador `-+-` y filas; avisa «(sin filas)» si está vacío. |
| `if __name__ == "__main__"` | Prueba rápida: muestra versión del servidor, base y cuenta. |

#### `conexion_mariabd.py`

Ejemplo mínimo con el conector oficial `mariadb`. Importa `CONFIG` de `conexion.py` (que
lee el `.env`), por lo que usuario, contraseña, host, puerto y base salen de las variables
`GLOB_GUSTERS_*` y no hay valores escritos en el código; convierte `localhost` en `127.0.0.1`
para conectar por TCP, abre la conexión con `mariadb.connect(...)` (si falla imprime el error y
sale con código 1), crea un cursor, ejecuta `SELECT * FROM nacionalidad`, imprime
`ID` y `Nombre` de cada fila y cierra cursor y conexión.

#### `ddl.py`, `dml.py`, `dql.py`, `vdl.py`, `dcl.py`, `tcl.py`

| Archivo | Equivale a | Estructura y funcionamiento |
|---|---|---|
| `ddl.py` | `01_DDL.sql` | La lista `SENTENCIAS` contiene el mismo DDL del `.sql`. `main()` abre la conexión, ejecuta cada sentencia imprimiendo `OK:` y los primeros 90 caracteres, hace `commit()` y consulta `information_schema.columns` para mostrar las columnas `Email`, `Telefono` y `Duracion_Minutos`. |
| `dml.py` | `02_DML.sql` | `main()` ejecuta con parámetros: `INSERT IGNORE` del socio nuevo (aval en tabla derivada), `UPDATE` del estado de Quo Vadis #2, `UPDATE` de la duración de Interstellar y `DELETE` del reparto de Anne Hathaway; imprime las filas afectadas de cada uno, hace `commit()` y muestra el socio nuevo. |
| `dql.py` | `03_DQL.sql` | El diccionario `CONSULTAS` mapea cuatro nombres (`disponibles`, `rentas_activas`, `peliculas_por_nacionalidad`, `ejemplares_por_estado`) a su título y SQL. `main(argv)` ejecuta todas o solo las nombradas; si alguna no existe sale con un mensaje y las opciones válidas. |
| `vdl.py` | `04_VDL.sql` | El diccionario `VISTAS` guarda, por vista, su `CREATE OR REPLACE VIEW` y su consulta de verificación. Con `--drop` ejecuta `DROP VIEW IF EXISTS` de ambas y termina; sin él crea y muestra cada vista. Siempre confirma con `commit()`. |
| `dcl.py` | `05_DCL.sql` | El diccionario `USUARIOS` lee las contraseñas de `GLOB_GUSTERS_PASS_*` (con los mismos valores por defecto). `main()` crea cada usuario con `CREATE USER IF NOT EXISTS ... IDENTIFIED BY %s`, concede sus privilegios, revoca `DELETE` al mostrador, ejecuta `FLUSH PRIVILEGES` y muestra `SHOW GRANTS` de cada cuenta. |
| `tcl.py` | `06_TCL.sql` | Busca el cliente por DNI y el ejemplar por título+año+número (sale con mensaje si faltan). Calcula `ya_existe`. Ejemplo 1: `con.begin()`; si no existe, inserta la renta, guarda `lastrowid`, crea `SAVEPOINT`, inserta el detalle y, si el trigger de máximo 4 lo rechaza, hace `ROLLBACK TO SAVEPOINT`; cualquier otro error hace `rollback()` y se relanza; luego `commit()`. Ejemplo 2: cambia una dirección, la lee, hace `rollback()` y la lee de nuevo para mostrar que se restauró. |

### Carpeta `java/`

Todas las clases están en el paquete por defecto y usan `Conexion`. Compilación y
ejecución: ver «Conexión y consultas desde Java».

#### `Conexion.java` — clase base

| Elemento | Qué hace |
|---|---|
| Imports y Javadoc | Entrada/salida de archivos, `java.sql.*` (JDBC) y colecciones; el Javadoc describe el comando equivalente y las variables. |
| `configurarSalida()` | Si la salida no va a una terminal, reemplaza `System.out` y `System.err` por `PrintStream` en UTF-8 (en una terminal respeta la codificación que el JDK eligió para la consola). Cada `main` la llama en su primera línea. `esTerminal()` decide con `System.console()` y, en JDK 22+, con `Console.isTerminal()` por reflexión. |
| `correr(Principal)` | Ejecuta el programa; si el servidor informa una tabla dañada (mismos errores que en Python) imprime los pasos de reparación y sale con código 1; cualquier otro error se propaga igual. Cada `main` la usa (`Conexion.correr(() -> principal(args))`). |
| `ENV_ARCHIVO` | Mapa que se llena al iniciar la clase con `cargarEnv()`; se declara antes que las constantes que lo usan. |
| `HOST`, `PORT`, `USER`, `PASSWORD`, `DB` | Constantes de configuración obtenidas con `env(...)` (el puerto se convierte con `Integer.parseInt`). |
| `env(nombre, defecto)` | Devuelve primero la variable del sistema, luego la del `.env` y por último el valor por defecto. |
| `cargarEnv()` | Busca `.env` en el directorio actual y, si no está, en el padre; lee cada línea, ignora vacías/comentarios/sin `=`, quita `export ` de la clave y las comillas del valor, y usa solo el primer archivo encontrado. Si no puede leerlo, avisa por `stderr`. |
| `conectar()` / `conectar(usuario, clave)` | Arma la URL `jdbc:mariadb://host:puerto/base?characterEncoding=utf8`, abre la conexión y apaga el autocommit. Ante el error 1045 imprime en `stderr` el mismo mensaje que Python (sin contraseña / usuario o contraseña incorrectos, con usuario, host y puerto, sin mostrar la clave) y sale con código 1; el 1049 (base inexistente) imprime en `stderr` que hay que ejecutar primero `glob_gusters.sql` y `glob_gusters_insert.sql` y también sale con código 1; relanza los demás. (La línea `[ WARN]` que aparece antes es del propio driver JDBC.) |
| `consultar(con, sql, params...)` | Prepara y ejecuta un `SELECT`/`SHOW` y devuelve una lista de mapas columna→valor en orden; las columnas `YEAR` se leen como `Integer` para mostrar solo el año. |
| `ejecutar(con, sql, params...)` | Ejecuta una escritura con `executeUpdate()` y devuelve las filas afectadas (sin commit). |
| `preparar(...)` | Crea el `PreparedStatement` y asigna los parámetros por posición (desde 1). |
| `imprimir(titulo, filas)` y `unir(...)` | Calculan el ancho de cada columna y escriben la tabla alineada (encabezado, separador `-+-`, filas); «(sin filas)» si está vacío. |
| `main` | Prueba rápida: versión del servidor, base y cuenta. |

#### `Ddl.java`, `Dml.java`, `Dql.java`, `Vdl.java`, `Dcl.java`, `Tcl.java`

Son los equivalentes en Java de `ddl.py`, `dml.py`, `dql.py`, `vdl.py`, `dcl.py` y `tcl.py`;
la tabla de «Conexión y consultas desde Java» resume cada una. Diferencias de
implementación:

| Clase | Detalle |
|---|---|
| `Ddl` | `SENTENCIAS` es un `List.of(...)` de *text blocks*; el resumen impreso limita a 90 caracteres con `substring`. |
| `Dml` | Usa `?` como marcador y `Conexion.ejecutar` con los mismos valores que Python. |
| `Dql` | `record Consulta(titulo, sql)` y un `LinkedHashMap` llenado en un bloque `static`; valida los nombres recibidos antes de conectar y sale con código 1 si alguno es desconocido. |
| `Vdl` | `record Vista(crear, consulta)`; con `--drop` elimina las vistas y termina. |
| `Dcl` | `record Cuenta(clave, privilegios)`; las contraseñas salen de `Conexion.env(...)`. |
| `Tcl` | Usa `Savepoint` de JDBC (`con.setSavepoint` / `con.rollback(sp)`) y el método auxiliar `insertarRenta`, que pide `RETURN_GENERATED_KEYS` para obtener el `Renta_ID`. |

### Carpeta `tests/`

#### `tests/mariadb/glob_gusters_test.sql` — pruebas de integridad

Se ejecuta tras los ocho scripts del proyecto (`--force` ya no es obligatorio). Crea la tabla temporal
`test_results` (`Test_ID`, `Nombre_Prueba`, `Resultado ENUM('PASS','FAIL')`, `Detalle`),
inserta una fila por prueba con `INSERT ... SELECT` y al final muestra el detalle, un
resumen (total, aprobadas, fallidas y veredicto «PROYECTO OK»/«REVISAR FALLAS») y
elimina la tabla temporal. No usa procedimientos almacenados.

| Prueba | Qué verifica |
|---|---|
| 1 | Existen 11 tablas base (`information_schema.tables`). |
| 2 | Existen 2 vistas. |
| 3 | Existen 4 triggers. |
| 4 | Cada una de las 11 tablas tiene al menos una fila (11 comprobaciones). |
| 5 | No hay ejemplares ni rentas huérfanos (2 comprobaciones). |
| 6 | El trigger de auto-aval rechaza un cliente que se avale a sí mismo (intenta insertar el ID 999001, captura el rechazo, comprueba su mensaje y que la fila no existe, y limpia). |
| 7 | El trigger de máximo 4: crea un socio de prueba, intenta registrar 5 ejemplares y comprueba que solo quedaron 4 y que el quinto fue rechazado con su mensaje; luego limpia. |
| 7b | Con 4 ejemplares sin devolver, un renglón ya devuelto (`Entrega` con fecha) sí se admite; limpia al terminar. |
| 7c | Reabrir esa devolución (`Entrega = NULL`) con 4 ya sin devolver es rechazado por `trg_ejemplar_renta_max_4_update`. |
| 8 | El `CHECK` de `renta` rechaza `Termina` anterior a `Inicia`. |
| 9 | Las vistas devuelven tantas filas como sus tablas base (2 comprobaciones). |
| 10 | `glob_gusters_reportes` solo tiene `SELECT` y `glob_gusters_mostrador` no tiene `DELETE` (2 comprobaciones). |

Cada prueba que inserta datos primero borra restos de una corrida interrumpida y limpia al
final, por lo que es repetible.

### Flujo completo de ejecución y dependencias entre archivos

```
.env.example ──copia──▶ .env ──leído por──▶ py/conexion.py ──▶ py/ddl|dml|dql|vdl|dcl|tcl.py
                                       └──▶ java/Conexion.java ──▶ java/Ddl|Dml|Dql|Vdl|Dcl|Tcl.java

sql/mariadb/glob_gusters.sql ▶ glob_gusters_insert.sql ▶ commands/01 ▶ 02 ▶ 03 ▶ 04 ▶ 05 ▶ 06
                                                                    └─▶ tests/mariadb/glob_gusters_test.sql
sql/oracle_apex/00 ▶ 00b ▶ 01 ▶ 02 ▶ 03 ▶ 04 ▶ 05 ▶ 06
requirements.txt ──▶ .venv (Python)        java/lib/*.jar (JDBC) ──▶ java/out (clases compiladas)
```

- Los scripts `py/` y `java/` dependen de que la base ya exista (`glob_gusters.sql` e
  inserts) y, `dml`/`dql`/`vdl`, de que `ddl` haya agregado `Email` y `Duracion_Minutos`.
- `dcl` necesita una cuenta administrativa; `tcl` necesita los datos de ejemplo.
- Las pruebas de `tests/` comprueban el resultado de todos los scripts anteriores.

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
