#!/usr/bin/env bash
# =====================================================================================
# ejecutar-sql.sh — Ejecuta todos los scripts SQL de MariaDB (Linux y macOS)
# =====================================================================================
# Primero comprueba las versiones: muestra la del cliente y la del servidor y avisa si el
# servidor es anterior a MariaDB 10.2.1 (no instala nada ni pide permisos de administrador).
#
# Orden: glob_gusters.sql -> glob_gusters_insert.sql -> commands/01_DDL ... 06_TCL,
# y después las pruebas de integridad y el diagnóstico del servidor (ambos de solo
# lectura sobre los datos). Los scripts son repetibles. Si falla la creación de la base
# (los 2 primeros scripts) muestra el error y detiene SQL, Python y Java; si falla
# cualquiera de los otros 6 scripts, muestra el error y detiene el programa. Las pruebas
# deben terminar con 'PROYECTO OK'; las pruebas y el diagnóstico se ejecutan con --force porque es
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

uso() { sed -n '2,21p' "$0" | sed 's/^# \{0,1\}//'; }
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

info "Comprobando las versiones del cliente y del servidor"
info "Cliente: $("$CLIENTE" --version 2>/dev/null | sed -n 1p)"
VERSION_SERVIDOR=$("$CLIENTE" -h "$HOST" -P "$PORT" -u "$USUARIO" -N -s -e "SELECT VERSION()" 2>/dev/null | sed -n 1p)
if [ -z "$VERSION_SERVIDOR" ]; then
    aviso "No se pudo consultar la versión del servidor (¿está en marcha y son correctas las credenciales?)."
else
    # Algunas versiones anteponen "5.5.5-" (compatibilidad de replicación); se quita para comparar.
    NUMERO=$(printf '%s' "${VERSION_SERVIDOR#5.5.5-}" | sed -E 's/^([0-9]+)\.([0-9]+)\.([0-9]+).*/\1 \2 \3/')
    set -- $NUMERO
    if [ "$#" -eq 3 ] && [ $(( $1 * 1000000 + $2 * 1000 + $3 )) -ge 10002001 ]; then
        ok "Servidor $VERSION_SERVIDOR (se requiere MariaDB 10.2.1 o superior)."
    else
        aviso "Servidor $VERSION_SERVIDOR: los scripts requieren MariaDB 10.2.1 o superior y pueden fallar."
    fi
fi

# Los dos primeros scripts crean la base de datos, las tablas y los datos; si fallan no
# tiene sentido seguir con nada más (ni SQL, ni Python, ni Java). El resto de los scripts
# también detiene el programa en el primer error. El cliente imprime el error en pantalla.
N=0
for f in "${SQL_SCRIPTS[@]}"; do
    N=$((N + 1))
    info "$f"
    if ! "$CLIENTE" -h "$HOST" -P "$PORT" -u "$USUARIO" --default-character-set=utf8mb4 < "$f"; then
        if [ "$N" -le 2 ]; then
            falla "Falló la creación de la base de datos (tablas e inserción de datos) en $f."
            falla "Se detiene la ejecución de los demás scripts SQL, de Python y de Java."
        else
            falla "Falló el script $f. Se detiene la ejecución del programa."
        fi
        exit 1
    fi
done
ok "La base de datos y los ${#SQL_SCRIPTS[@]} scripts SQL terminaron sin errores."

if [ "$PRUEBAS" -eq 1 ]; then
    info "tests/mariadb/glob_gusters_test.sql (debe terminar con 'PROYECTO OK')"
    SALIDA_PRUEBAS=$(mktemp)
    "$CLIENTE" -h "$HOST" -P "$PORT" -u "$USUARIO" --default-character-set=utf8mb4 --force "$BASE" \
        < tests/mariadb/glob_gusters_test.sql 2>&1 | tee "$SALIDA_PRUEBAS"
    CODIGO=${PIPESTATUS[0]}
    # Además del código de salida se exige el veredicto "PROYECTO OK" (0 pruebas fallidas).
    if [ "$CODIGO" -ne 0 ] || ! grep -q "PROYECTO OK" "$SALIDA_PRUEBAS"; then
        rm -f "$SALIDA_PRUEBAS"
        falla "Fallaron las pruebas (no se obtuvo 'PROYECTO OK'). Se detiene la ejecución del programa."
        exit 1
    fi
    rm -f "$SALIDA_PRUEBAS"
fi

if [ "$DIAGNOSTICO" -eq 1 ]; then
    info "sql/mariadb/check-mariadb.sh (diagnóstico del servidor)"
    sh sql/mariadb/check-mariadb.sh || aviso "El diagnóstico terminó con avisos (ver mensajes arriba)."
fi
ok "SQL completado."
