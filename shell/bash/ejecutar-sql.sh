#!/usr/bin/env bash
# =====================================================================================
# ejecutar-sql.sh — Ejecuta todos los scripts SQL de MariaDB (Linux y macOS)
# =====================================================================================
# Orden: glob_gusters.sql -> glob_gusters_insert.sql -> commands/01_DDL ... 06_TCL,
# y después las pruebas de integridad y el diagnóstico del servidor (ambos de solo
# lectura sobre los datos). Los scripts son repetibles. Se detiene en el primer error
# de los 8 scripts; las pruebas y el diagnóstico se ejecutan con --force porque es
# normal que impriman algunos ERROR esperados (ver README).
#
# Uso (desde cualquier carpeta):
#     bash shell/bash/ejecutar-sql.sh [--sin-pruebas] [--sin-diagnostico]
#
# Si el cliente no está en el PATH:  MARIADB_BIN=/ruta/a/mariadb bash shell/bash/ejecutar-sql.sh
# Si root tiene contraseña: defínela en .env (GLOB_GUSTERS_PASSWORD) o en el entorno.
# =====================================================================================
set -u
. "$(dirname "$0")/lib.sh"

uso() { sed -n '2,16p' "$0" | sed 's/^# \{0,1\}//'; }
PRUEBAS=1; DIAGNOSTICO=1
for arg in "$@"; do
    case "$arg" in
        -h|--help) uso; exit 0 ;;
        --sin-pruebas) PRUEBAS=0 ;;
        --sin-diagnostico) DIAGNOSTICO=0 ;;
        *) falla "Opción desconocida: $arg"; uso; exit 2 ;;
    esac
done

cargar_conexion
localizar_cliente
cd "$RAIZ" || exit 1
info "Servidor: $USUARIO@$HOST:$PORT  (cliente: $CLIENTE)"

for f in "${SQL_SCRIPTS[@]}"; do
    info "$f"
    if ! "$CLIENTE" -h "$HOST" -P "$PORT" -u "$USUARIO" --default-character-set=utf8mb4 < "$f"; then
        falla "Falló $f. ¿Está el servidor en marcha y son correctas las credenciales?"
        exit 1
    fi
done
ok "Los ${#SQL_SCRIPTS[@]} scripts SQL terminaron sin errores."

if [ "$PRUEBAS" -eq 1 ]; then
    info "tests/mariadb/glob_gusters_test.sql (debe terminar con 'PROYECTO OK')"
    "$CLIENTE" -h "$HOST" -P "$PORT" -u "$USUARIO" --default-character-set=utf8mb4 --force "$BASE" \
        < tests/mariadb/glob_gusters_test.sql || { falla "Fallaron las pruebas."; exit 1; }
fi

if [ "$DIAGNOSTICO" -eq 1 ]; then
    info "sql/mariadb/check-mariadb.sh (diagnóstico del servidor)"
    sh sql/mariadb/check-mariadb.sh || aviso "El diagnóstico terminó con avisos (ver mensajes arriba)."
fi
ok "SQL completado."
