#!/usr/bin/env bash
# =====================================================================================
# ejecutar-todo.sh — Ejecuta SQL, Python y Java en orden (Linux y macOS)
# =====================================================================================
# Llama a ejecutar-sql.sh, ejecutar-python.sh y ejecutar-java.sh, y se detiene en el
# primer fallo de SQL o Java (si Python falla, avisa y continúa con Java). Acepta --sin-python y --sin-java para omitir un lenguaje.
#
# Uso (desde cualquier carpeta):
#     bash shell/bash/ejecutar-todo.sh [--sin-python] [--sin-java]
# =====================================================================================
set -u
AQUI=$(cd "$(dirname "$0")" && pwd)
. "$AQUI/lib.sh"

uso() { sed -n '2,8p' "$0" | sed 's/^# \{0,1\}//'; }
PY=1; JV=1
for arg in "$@"; do
    case "$arg" in
        -h|--help) uso; exit 0 ;;
        --sin-python) PY=0 ;;
        --sin-java) JV=0 ;;
        *) falla "Opción desconocida: $arg"; uso; exit 2 ;;
    esac
done

bash "$AQUI/ejecutar-sql.sh" || exit 1
PY_FALLO=0
if [ "$PY" -eq 1 ]; then
    if ! bash "$AQUI/ejecutar-python.sh"; then
        PY_FALLO=1
        aviso "Los scripts de Python se detuvieron (entorno virtual, dependencias o ejecución). Se continúa con Java."
    fi
fi
[ "$JV" -eq 1 ] && { bash "$AQUI/ejecutar-java.sh" || exit 1; }
if [ "$PY_FALLO" -eq 1 ]; then
    aviso "Proyecto ejecutado con advertencias: SQL y Java terminaron bien, pero Python no se completó."
else
    ok "Todo el proyecto se ejecutó correctamente."
fi
