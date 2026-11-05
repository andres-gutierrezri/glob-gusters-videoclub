#!/usr/bin/env bash
# =====================================================================================
# lib.sh — Funciones comunes de los lanzadores de Bash (Linux y macOS)
# =====================================================================================
# No se ejecuta directamente: los demás scripts de esta carpeta lo cargan con `source`.
#
# Define:
#   RAIZ                  Raíz del proyecto (dos niveles sobre shell/bash/).
#   SQL_SCRIPTS           Los 8 scripts SQL de MariaDB, en el orden en que se ejecutan.
#   info / ok / aviso / falla   Mensajes con color (solo si la salida es una terminal).
#   cargar_conexion       Resuelve host, puerto, usuario, clave y base (sistema > .env > defecto).
#   localizar_cliente     Encuentra el cliente `mariadb` (o `mysql`) y lo deja en CLIENTE.
#   asegurar_env          Crea .env desde .env.example si todavía no existe.
#
# Variables de conexión (las mismas que usan py/conexion.py y java/Conexion.java):
#   GLOB_GUSTERS_HOST, GLOB_GUSTERS_PORT, GLOB_GUSTERS_USER, GLOB_GUSTERS_PASSWORD,
#   GLOB_GUSTERS_DB. Además, MARIADB_BIN indica la ruta del cliente (opcional).
# =====================================================================================

RAIZ=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
ENV_ARCHIVO="$RAIZ/.env"

SQL_SCRIPTS=(
    "sql/mariadb/glob_gusters.sql"
    "sql/mariadb/glob_gusters_insert.sql"
    "sql/mariadb/commands/01_DDL.sql"
    "sql/mariadb/commands/02_DML.sql"
    "sql/mariadb/commands/03_DQL.sql"
    "sql/mariadb/commands/04_VDL.sql"
    "sql/mariadb/commands/05_DCL.sql"
    "sql/mariadb/commands/06_TCL.sql"
)

# ---- Mensajes -------------------------------------------------------------------------
if [ -t 1 ]; then
    C_AZUL=$'\033[1;34m'; C_VERDE=$'\033[1;32m'; C_AMARILLO=$'\033[1;33m'
    C_ROJO=$'\033[1;31m'; C_FIN=$'\033[0m'
else
    C_AZUL=""; C_VERDE=""; C_AMARILLO=""; C_ROJO=""; C_FIN=""
fi
info()  { printf '%s>>> %s%s\n' "$C_AZUL" "$*" "$C_FIN"; }
ok()    { printf '%s[OK] %s%s\n' "$C_VERDE" "$*" "$C_FIN"; }
aviso() { printf '%s[AVISO] %s%s\n' "$C_AMARILLO" "$*" "$C_FIN" >&2; }
falla() { printf '%s[ERROR] %s%s\n' "$C_ROJO" "$*" "$C_FIN" >&2; }

# ---- Lectura del .env -----------------------------------------------------------------
# leer CLAVE DEFECTO: valor de CLAVE en el .env o, si no está o está vacío, DEFECTO.
# No usa `source` ni `eval`: no ejecuta nada de lo que haya dentro del archivo.
leer() {
    local valor=""
    if [ -f "$ENV_ARCHIVO" ]; then
        valor=$(sed -n "s/^[[:space:]]*\(export[[:space:]][[:space:]]*\)\{0,1\}$1[[:space:]]*=[[:space:]]*//p" "$ENV_ARCHIVO" \
            | tail -n 1 \
            | sed -e 's/[[:space:]]*$//' -e "s/^\"\(.*\)\"$/\1/" -e "s/^'\(.*\)'$/\1/")
    fi
    if [ -n "$valor" ]; then printf '%s' "$valor"; else printf '%s' "$2"; fi
}

cargar_conexion() {
    HOST=${GLOB_GUSTERS_HOST:-$(leer GLOB_GUSTERS_HOST localhost)}
    PORT=${GLOB_GUSTERS_PORT:-$(leer GLOB_GUSTERS_PORT 3306)}
    USUARIO=${GLOB_GUSTERS_USER:-$(leer GLOB_GUSTERS_USER root)}
    if [ -n "${GLOB_GUSTERS_PASSWORD+x}" ]; then CLAVE=$GLOB_GUSTERS_PASSWORD; else CLAVE=$(leer GLOB_GUSTERS_PASSWORD ""); fi
    BASE=${GLOB_GUSTERS_DB:-$(leer GLOB_GUSTERS_DB glob_gusters)}
    # Con "localhost" el cliente usaría el socket Unix (posiblemente de otro servidor);
    # se fuerza TCP con 127.0.0.1.
    [ "$HOST" = "localhost" ] && HOST=127.0.0.1
    # El cliente lee la contraseña de MYSQL_PWD: así no aparece en la lista de procesos.
    if [ -n "$CLAVE" ]; then export MYSQL_PWD="$CLAVE"; fi
}

localizar_cliente() {
    CLIENTE=${MARIADB_BIN:-}
    if [ -z "$CLIENTE" ]; then
        local candidato
        for candidato in mariadb /Applications/XAMPP/xamppfiles/bin/mariadb /opt/lampp/bin/mariadb mysql; do
            if command -v "$candidato" >/dev/null 2>&1; then CLIENTE=$candidato; break; fi
        done
    fi
    if [ -z "$CLIENTE" ]; then
        falla "No se encontró el cliente 'mariadb' (ni 'mysql'). Instálalo o define MARIADB_BIN con su ruta."
        falla "Ejemplo: MARIADB_BIN=/Applications/XAMPP/xamppfiles/bin/mariadb sh shell/bash/ejecutar-sql.sh"
        exit 1
    fi
}

asegurar_env() {
    if [ ! -f "$ENV_ARCHIVO" ]; then
        cp "$RAIZ/.env.example" "$ENV_ARCHIVO"
        aviso "Se creó .env a partir de .env.example. Si tu usuario tiene contraseña, edita GLOB_GUSTERS_PASSWORD."
    fi
}

# Cierra con un mensaje de ayuda cuando se pide -h / --help (cada script define uso()).
ayuda_si_se_pide() {
    case "${1:-}" in -h|--help) uso; exit 0 ;; esac
}
