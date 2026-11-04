#!/bin/sh
# =====================================================================================
# check-mariadb.sh — Lanzador de check-mariadb.sql con la configuración del archivo .env
# =====================================================================================
# Un archivo SQL no puede leer el .env, así que este script lo hace por él: lee las
# variables de conexión, ejecuta el cliente `mariadb` con ellas y le pasa a
# check-mariadb.sql el nombre de la base de datos mediante la variable de sesión
# @glob_gusters_db.
#
# Variables que usa (las mismas de py/conexion.py y java/Conexion.java):
#   GLOB_GUSTERS_HOST       (por defecto localhost)
#   GLOB_GUSTERS_PORT       (por defecto 3306)
#   GLOB_GUSTERS_USER       (por defecto root)
#   GLOB_GUSTERS_PASSWORD   (por defecto vacía = sin contraseña)
#   GLOB_GUSTERS_DB         (por defecto glob_gusters)
# Prioridad: variable ya definida en el sistema > archivo .env > valor por defecto.
# Además, MARIADB_BIN permite indicar la ruta del cliente `mariadb` (opcional).
#
# Uso (desde cualquier carpeta):
#     sh sql/mariadb/check-mariadb.sh
# =====================================================================================

# Carpeta de este script y raíz del proyecto (dos niveles más arriba: sql/mariadb/ -> raíz).
RAIZ=$(cd "$(dirname "$0")/../.." && pwd)
ENV_ARCHIVO="$RAIZ/.env"

# leer CLAVE VALOR_POR_DEFECTO: devuelve el valor de CLAVE en el .env, o el valor por defecto.
# No usa `source` ni `eval` para no ejecutar nada que haya dentro del archivo.
leer() {
    valor=""
    if [ -f "$ENV_ARCHIVO" ]; then
        # Última línea CLAVE=valor (admite `export ` y espacios), quitando espacios y comillas.
        valor=$(sed -n "s/^[[:space:]]*\(export[[:space:]][[:space:]]*\)\{0,1\}$1[[:space:]]*=[[:space:]]*//p" "$ENV_ARCHIVO" \
            | tail -n 1 \
            | sed -e 's/[[:space:]]*$//' -e "s/^\"\(.*\)\"$/\1/" -e "s/^'\(.*\)'$/\1/")
    fi
    # Si el .env no define la clave o la deja vacía, se devuelve el valor por defecto.
    if [ -n "$valor" ]; then printf '%s' "$valor"; else printf '%s' "$2"; fi
}

# Resuelve cada variable: primero el entorno del sistema, luego el .env, luego el defecto.
# La contraseña no tiene defecto distinto de vacío; si el sistema la define (aunque sea
# vacía) se respeta.
HOST=${GLOB_GUSTERS_HOST:-$(leer GLOB_GUSTERS_HOST localhost)}
PORT=${GLOB_GUSTERS_PORT:-$(leer GLOB_GUSTERS_PORT 3306)}
USUARIO=${GLOB_GUSTERS_USER:-$(leer GLOB_GUSTERS_USER root)}
if [ -n "${GLOB_GUSTERS_PASSWORD+x}" ]; then CLAVE=$GLOB_GUSTERS_PASSWORD; else CLAVE=$(leer GLOB_GUSTERS_PASSWORD ""); fi
BASE=${GLOB_GUSTERS_DB:-$(leer GLOB_GUSTERS_DB glob_gusters)}

# Con "localhost" el cliente usaría el socket Unix local (que puede ser de otro servidor
# MySQL/MariaDB e ignora el puerto); se fuerza TCP con 127.0.0.1.
[ "$HOST" = "localhost" ] && HOST=127.0.0.1

# Localiza el cliente: MARIADB_BIN, el del PATH o las rutas típicas de XAMPP.
CLIENTE=${MARIADB_BIN:-}
if [ -z "$CLIENTE" ]; then
    for candidato in mariadb /Applications/XAMPP/xamppfiles/bin/mariadb /opt/lampp/bin/mariadb mysql; do
        if command -v "$candidato" >/dev/null 2>&1; then CLIENTE=$candidato; break; fi
    done
fi
if [ -z "$CLIENTE" ]; then
    echo "No se encontró el cliente 'mariadb'. Define MARIADB_BIN con su ruta." >&2
    exit 1
fi

# La contraseña viaja por la variable MYSQL_PWD (no aparece en la lista de procesos). Si
# está vacía no se define, y el cliente se conecta sin contraseña.
if [ -n "$CLAVE" ]; then MYSQL_PWD=$CLAVE; export MYSQL_PWD; fi

# Nombre de la base escapado para el literal SQL: se duplican las comillas simples y las barras.
BASE_SQL=$(printf '%s' "$BASE" | sed -e 's/\\/\\\\/g' -e "s/'/''/g")

# Ejecuta el script con --force (para que las secciones que fallen por las limitaciones
# conocidas del entorno no detengan el reporte). --init-command define @glob_gusters_db
# nada más conectar, antes de leer check-mariadb.sql de la entrada estándar.
exec "$CLIENTE" -h "$HOST" -P "$PORT" -u "$USUARIO" \
    --default-character-set=utf8mb4 --force \
    --init-command="SET @glob_gusters_db = '$BASE_SQL'" \
    < "$RAIZ/sql/mariadb/check-mariadb.sql"
